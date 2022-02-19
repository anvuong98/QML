function [LDOS_norm,U0] = generateldos(A, B, En, smo, nu, ld, ni, Kap)
%% Define Constants
%nu=2; % shape factor
X=470;Y=230; % size
Ni=max(1,round(ni*32*((X-smo/2)*(Y-smo/2))/smo^2)); % impurity number

m=0.044;
gi=0.0;
K=38/m; % energy units in meV using nm units
dx=10;
dy=dx;
x=0:dx:X;
y=0:dy:Y;
yn=-Y/(2*dx):Y/(2*dx);

Ub0=10.00; % depletion length and potential (defaut:ld=40)
Ub=Ub0*(exp(-abs(y)/ld)+exp(-abs(y-Y)/ld));
Lx=length(x);Ly=length(y);
lB2mn1=B/25.66^2;

%% Initialize vectors and matricies
Self0L=complex(zeros([24 24]),0);
Self0R=complex(zeros([24 24]),0);
psi=complex(zeros([24 48]),0);


%% Disorder Potential
va=2;
vi=va*(rand(Ni,1)-.5);
xi=rand(Ni,1)*(X-smo/2)+smo/4;
yi=rand(Ni,1)*(Y-smo/2)+smo/4;

U=0;
%% Switched Kap
for poti=1:Ni
    U=U+(1-Kap)*vi(poti) * exp(-4^2*(abs(y-yi(poti))).^nu/smo^nu)' * ...
        exp(-4^2*(abs(x-xi(poti))).^nu/smo^nu)+ ...
        Kap*vi(poti)./((1)*ones([length(y),length(x)]) + ...
        repmat(4^2*(abs(x-xi(poti))).^nu/smo^nu,length(y),1) + ...
        repmat(4^2*((abs(y-yi(poti))).^nu/smo^nu)',1,length(x)));
end

U = U - mean(mean(U));
U = U / sqrt(sum(sum(U.^2))/(24*48));
U0=U;
U0=A*U0;

%% sneaky for loop
E=En; % energy in meV

% Green's function along one direction
bdY=1;
t=1;Eg=-dx^2*E/K;
VB=-4;
E0=0.0; % electric field in mV/nm
U=U0+E0*dx*(yn'*ones(1,Lx))+Ub'*ones(1,Lx);

V=VB-dx^2*U/K+gi*(rand(Ly,Lx)-.5);V0=VB-dx^2*(U-U0)/K;
th=2;

XL=Ly+0;
HL=diag(ones(XL-1,1),1)+diag(ones(XL-1,1),-1)+diag(V0(:,1)); 
% Hamiltonian of the lead
HL(1,end)=bdY;HL(end,1)=bdY;
[V2,E2]=eig(HL); E2=diag(E2);
k1=real(acos((Eg-E2)/(2*t)))+1i*abs(imag(acos((Eg-E2)/(2*t))));
for x1=1:Ly
    for x2=1:Ly
        Self0R(x1,x2) = sum(V2(x1,:) .* conj(V2(x2,:))...
                                     .*transpose(exp(1i*k1)))*t^2;
    end
end
HL=diag(ones(XL-1,1),1)+diag(ones(XL-1,1),-1)+diag(V0(:,1));
HL(1,end)=bdY;HL(end,1)=bdY;
[V2,E2]=eig(HL);E2=diag(E2);
k1=real(acos((Eg-E2)/(2*t)))+1i*abs(imag(acos((Eg-E2)/(2*t))));

for x1=1:Ly
    for x2=1:Ly
        Self0L(x1,x2) = ...
        sum(V2(x1,:) .* conj(V2(x2,:)) ...
                     .* transpose(exp(1i*k1))) * t^2;
    end
end

T=diag(exp(.5*th*1i*(lB2mn1*dx^2)*yn));
Gn=Self0R;

%% First Iteration from end to start
Emat=(Eg-1e-10*1i)*eye(Ly);
for n=Lx:-1:1 
    Vn=V(:,n);
    Hn=diag(Vn)+diag(ones(Ly-1,1),1)+diag(ones(Ly-1,1),-1);
    Hn(1,end)=bdY;Hn(end,1)=bdY;
    Gn=inv(Emat-Hn-T*Gn*T');Gn1{n}=Gn;
end

%% Second Iteration from start to end
Gn2=Self0L;
G1n2=T';
psi0=-1i*ones(Ly,1);

for n=1:Lx-1
    Vn=V(:,n);
    Hn=diag(Vn)+diag(ones(Ly-1,1),1)+diag(ones(Ly-1,1),-1);
    Hn(1,end)=bdY;Hn(end,1)=bdY;
    Gn=inv(Emat-Hn-T*Gn1{n+1}*T'-T'*Gn2*T);
    Gn2=inv(Emat-Hn-T'*Gn2*T);
    G1n=G1n2*T*Gn;
    G1n2=G1n2*T*Gn2;
    psi(:,n)=-G1n'*psi0;
    LDOS(:,n)=imag(diag(Gn));
end

n=Lx;
Vn=V(:,n);
Hn=diag(Vn)+diag(ones(Ly-1,1),1)+diag(ones(Ly-1,1),-1);
Hn(1,end)=bdY;Hn(end,1)=bdY;
Gn=inv(Emat-Hn-Self0R-Gn2);
LDOS(:,n)=imag(diag(Gn));

LDOS_norm(:,:)=LDOS/max(max(LDOS));
/*
Projeto 42 de CVoo:
    - Francisco dos Santos, 86631
    - Miguel Morgado, 86668
*/

function p = poles_i(ss)
    [wn, z] = damp(ss)
    p = zeros(size(wn, '*'), 1);
    for i = 1:size(wn, '*');
        p(i) = -wn(i)*(z(i) + %i*sqrt(1-z(i)^2));
    end
endfunction

fp = './Feed-Back Loop System.zcos'

g = 9.81; deg=%pi/180; kts=0.514444444;
// --jas39 : flight condition : 1
h =50; M =0.25; aa0 =3.69*deg; gg0 =0; u0 =165.1*kts; flaps =8*deg; theta0 = aa0+gg0;
Teng =0.50; demax =[-22*deg, 28*deg]; damax =18*deg; drmax =23*deg; flapmax =40*deg;
th0 =29; de0 =0.00; da0 =0.00; dr0 =0.00; g=9.81;
//inertial data :
m =10049; Ix =1434311; Iy =65079; Iz =1385502; Ixz =1763;
//wing data :
S =25.55; b =8.382; c =2.235; aamax =19.69;
//derivatives (no units or SI units ):
xu=-0.0434; xw=0.0741; zu=-0.2457; zw=-0.7104; zwp=-0.0046; zq=-1.0386; mu=0.0000; mw=-0.0557; mq=-0.7485; mwp=-0.0365;
ybb=-0.0438; lbb=-0.0379; nbb=0.1723; yp=0.0007; lp=-0.7252; np=0.0017; yr=0.0019; lr=0.0073; nr=-0.0222;
xde=0.000; zde=-0.002; mde=-0.003; xdsp=0.000; zdsp=0.000; mdsp=-0.077; xdt=7.650; zdt=0.000; mdt=0.000;
Lda=-0.384; Nda=-0.029; Ydr=-0.001; Ldr=-0.000; Ndr=-0.003;
tt0=gg0+aa0; //theta_zero

A = [ybb, yp+aa0, yr-1, (g/u0)*cos(tt0), 0;
    lbb+(Ixz/Ix)*nbb, lp+(Ixz/Ix)*np, lr+(Ixz/Ix)*nr, 0, 0;
    nbb+(Ixz/Iz)*lbb, np+(Ixz/Iz)*lp, nbb+(Ixz/Iz)*lbb, 0, 0;
    0, 1, tan(tt0), 0, 0;
    0, 0, 1/cos(tt0), 0, 0];
B=  [0, Ydr;
    Lda+(Ixz/Ix)*Nda, Ldr+(Ixz/Ix)*Ndr;
    Nda+(Ixz/Iz)*Lda, Ndr+(Ixz/Iz)*Ldr;
    0, 0;
    0, 0];
C = diag([1,1,1,1,1]);
ee=syslin('c',A,B,C) //ee=espaço de estados  

//------------Calculando os polos, frequencias e amortecimentos -----------------
//p = poles_i(ee);
//disp(p,"Polos do sistema sem.controlador");
//plzr(ee) // função que te desenha os pólos (e zeros) no plano complexo
//[wn,z]=damp(ee); //dá os Wn e os qsi dos 5 pólos
//T_eq=1./(wn.*z);

//------------SAE para o rolamento holandes -> realimentaçao de r-------------
C1=[0,0,1,0,0]
K=[0,0,0,0,0;
   0,0,-340,0,0]          

    
sae=syslin('c',A-B*K,B(:,2),C1);
//------------Calculando os polos, frequencias e amortecimentos -----------------
p = poles_i(sae);
plzr(sae) // função que te desenha os pólos (e zeros) no plano complexo
[wn,z]=damp(sae) //dá os Wn e os qsi dos 5 pólos
T_eq=1./(wn.*z);
disp([p,wn,z],"Polos do sistema realimentado");

//Mostra as funçoes de transferência para por no relatorio
[h]=ss2tf(ee);
h_a=h(:,1);
h_r=h(:,2);



//substituir poles_i por spec

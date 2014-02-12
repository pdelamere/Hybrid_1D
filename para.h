c para.h
c contains simulation parameter list for a barium release

c simulation domain dimensions
      PARAMETER (nx = 3, ny = 3, nz = 801)

c magnetic field and mass info for determining time step

      real b0_init,mproton,q,nf_init
      PARAMETER (b0_init = 1700e-9)    !was 0.2
      PARAMETER (mproton = 16*1.67e-27)      
      PARAMETER (q = 1.6e-19)        !electron charge (Coulombs)
      PARAMETER (nf_init = 3000e15)   !was 0.01

      real lambda_i

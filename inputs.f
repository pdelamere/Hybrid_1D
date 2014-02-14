      MODULE INPUTS

      USE dimensions
      USE mpi

      real b0_init
      integer mion
      integer mp
      real nf_init
      real dt_frac
      integer nt
      integer nout
      real vsw
      real vth
c      integer*4 Ni_max
      real Ni_tot_frac
      real dx_frac
      real nu_init_frac
      

      real mproton,q
c      PARAMETER (b0_init = 1700e-9)    !was 0.2

      PARAMETER (q = 1.6e-19)        !electron charge (Coulombs)
c      PARAMETER (nf_init = 3000e15)   !was 0.01

      real lambda_i

c grid parameters

      real dx,dy, delz, dt, dtsub_init

c time stepping parameters
c      PARAMETER (nt = 10)          !number of time steps
      !PARAMETER (dtsub_init = 0.005) !subcycle time step 
      PARAMETER (ntsub = 10.0)        !number of subcycle time steps
      !PARAMETER (dt = dtsub_init*ntsub)     !main time step
c      PARAMETER (nout = 20)      !number of steps to diagnosic output 

c output directory
      character(50) out_dir
      PARAMETER (out_dir='./tmp3/')

c logical variable for restart
      logical restart
      PARAMETER (restart = .false.)
      PARAMETER (mrestart = 6000)      ! use -1 for no save
      PARAMETER (mbegin = 0)      !mstart

c neutral cloud expansion characteristics
      real vtop,vbottom
c      PARAMETER(vo = 20.0)
c      PARAMETER(vth = 10.0)
      PARAMETER(vsat = 0.0)
c      PARAMETER(vsw = 0.0*57.0)


c max number of ion particles to be produced.  This parameter
c is used to dimension the particle arrays.
c      integer*4 Ni_max, Ni_tot_0
      integer*4 Ni_tot_0
c      PARAMETER (Ni_max = 300000)


c misc constants
      real mu0,epsilon,pi,rtod,mO,mBa,O_to_Ba,km_to_m,kboltz,melec
      real tempf0,m_pu
      PARAMETER (pi = 3.14159)
      PARAMETER (rtod = 180.0/pi)  !radians to degreesc
      PARAMETER (mu0 = pi*4.0e-7)  !magnetic permeability of free space
      PARAMETER (epsilon = 8.85e-12) !dielectric constant
c      PARAMETER (melec = 9.1e-31)  !mass of electron (kg)

c      PARAMETER (mO = 2.3e-25)    !mass of Ba (kg)
      PARAMETER (m_pu = 64.0)

      PARAMETER (km_to_m = 1e3)    !km to meters conversion
      PARAMETER (kboltz = 1.38e-29)   !kg km^2 / s^2 / K
      PARAMETER (tempf0 = 50*11600.)     !K

      real nn_coef,np_top,np_bottom
      real b0_top,b0_bottom,Lo,vth_top,vth_bottom,vth_max
      real m_top, m_bottom,m_heavy,np_bottom_proton


c electron ion collision frequency
      real nu_init, eta_init,lww1,lww2

      PARAMETER (eta_init = 0.0)
      PARAMETER (lww2 = 1.0)    !must be less than 1.0
      PARAMETER (lww1 = (1-lww2)/6.0)  !divide by six for nearest neighbor

c density scaling parameter, alpha, and ion particle array dims
       
      real alpha  
c      PARAMETER (alpha = 1.9263418e-20) !mH...determines particle scaling

      CONTAINS
      
      subroutine readInputs()
      open(unit=100, file='inputs.dat', status='old')
      
      read(100,*) b0_init
      write(*,*) 'b0_init...',b0_init
      read(100,*) mion
      write(*,*) 'mion......',mion
      read(100,*) mpu
      write(*,*) 'mpu.......',mpu
      read(100,*) nf_init
      write(*,*) 'nf_init...',nf_init
      read(100,*) dt_frac
      write(*,*) 'dt_frac...',dt_frac
      read(100,*) nt
      write(*,*) 'nt........',nt
      read(100,*) nout
      write(*,*) 'nout......',nout
      read(100,*) vsw
      write(*,*) 'vsw.......',vsw
      read(100,*) vth
      write(*,*) 'vth.......',vth
c      read(100,*) Ni_max
c      write(*,*) 'Ni_max....',Ni_max
      read(100,*) Ni_tot_frac
      write(*,*) 'Ni_tot_frac..',Ni_tot_frac
      read(100,*) dx_frac
      write(*,*) 'dx_frac....',dx_frac
      read(100,*) nu_init_frac
      write(*,*) 'nu_init_frac...',nu_init_frac

     
      close(100)
      end subroutine readInputs

      subroutine initparameters()
      mproton = mion*1.67e-27

      lambda_i = (3e8/
     x            sqrt((nf_init/1e9)*q*q/(8.85e-12*mproton)))/1e3

      dx = lambda_i*dx_frac 
      dy = lambda_i*dx_frac   !units in km
      delz = lambda_i*dx_frac          !dz at release coordinates
                                       !this is not the final dz
                                       !d_lamba determines dz

      dt = dt_frac*mproton/(q*b0_init)     !main time step
      dtsub_init = dt/ntsub !subcycle time step 


      vtop = vsw
      vbottom = -vsw


      Ni_tot_0 = Ni_max*Ni_tot_frac

      write(*,*) 'Ni_tot_0...',Ni_tot_0, Ni_max,Ni_tot_frac

      mO = mproton    !mass of H (kg)



      mBa = m_pu*mO    !mass of Ba (kg)
      O_to_Ba = mO/mBa !convert E and B for particle move

      m_heavy = 1.0
      np_top = nf_init
      np_bottom = nf_init/m_heavy
      f_proton_top = 0.5       !fraction relative to top
      b0_top = 1.0*b0_init
      b0_bottom = b0_init
      vth_top = 30.00
      vth_bottom = 30.00
      vth_max = 3*30.0
      m_top = mproton
      m_bottom = mproton
      nn_coef = 1e5
      Lo = 4.0*dx             !gradient scale length of boundary

      nu_init = nu_init_frac*q*b0_init/mproton

      alpha = (mu0/1e3)*q*(q/mproton) !mH...determines particle scaling
      end subroutine initparameters


      subroutine check_inputs()
   !----------------------------------------------------------------------
   !   check input parameters
   !----------------------------------------------------------------------

      if (my_rank .eq. 0) then 
      write(*,*) 'alpha...',alpha
      write(*,*) 'c/wpi...',lambda_i,dx,dy,delz
      write(*,*) 'dt......',dt,dtsub_init

      write(*,*) ' '
      write(*,*) 'Bottom parameters...'
      write(*,*) ' '
      va =  b0_init/sqrt(mu0*m_bottom*np_bottom/1e9)/1e3
      write(*,*) 'Alfven velocity.......',va
      write(*,*) 'Thermal velocity......',vth_top
      write(*,*) 'Mach number...........',vbottom/(va + vth_bottom)

      write(*,*) 'Thermal gyroradius..',m_bottom*vth_bottom/(q*b0_init),
     x            m_bottom*vth_bottom/(q*b0_init)/dx
      cwpi = 3e8/sqrt((np_bottom/1e9)*q*q/(epsilon*m_bottom))
      write(*,*) 'Ion inertial length...',cwpi/1e3,cwpi/1e3/dx

c      write(*,*) 'Particles per cell....',Ni_tot_sys/(nx*nz)

      write(*,*) ' '
      write(*,*) 'Top parameters...'
      write(*,*) ' '

      va =  b0_init/sqrt(mu0*m_top*np_top/1e9)/1e3
      write(*,*) 'Alfven velocity.......',va
      write(*,*) 'Thermal velocity......',vth_top
      write(*,*) 'Mach number...........',vtop/(va + vth_top)

      write(*,*) 'Thermal gyroradius....',m_top*vth_top/(q*b0_init),
     x            m_top*vth_top/(q*b0_init)/dx
      cwpi = 3e8/sqrt((np_top/1e9)*q*q/(epsilon*m_top))
      write(*,*) 'Ion inertial length...',cwpi/1e3,cwpi/1e3/dx


      endif

   !----------------------------------------------------------------------
      end subroutine check_inputs


      
      END MODULE
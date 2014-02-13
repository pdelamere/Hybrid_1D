      MODULE INPUTS

c      USE input_const
ca module to read and store inputs from input.dat
cshould only be used in onebox.f90
cvariables will be global to eliminate the need for passing variables

      real b0_init
      integer mion
      integer mp
      real nf_init
      real dt_frac
      integer nt
      integer nout
      real vsw
      real vth
      integer*4 Ni_max
      real Ni_tot_frac
      real dx_frac
      
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
      read(100,*) Ni_max
      write(*,*) 'Ni_max....',Ni_max
      read(100,*) Ni_tot_frac
      write(*,*) 'Ni_tot_frac..',Ni_tot_frac
      read(100,*) dx_frac
      write(*,*) 'dx_frac....',dx_frac
      
      close(100)
      end subroutine readInputs
      
      END MODULE

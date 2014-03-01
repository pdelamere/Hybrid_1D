c----------------------------------------------------------------------
      SUBROUTINE crossf(aa,bbmf,cc)
c The cross product is formed at the main cell center.  a is assumed
c be main cell contravarient (cell face) and b is assumed to be
c main cell covarient (cell edge).  The result is main cell
c contravarient (cell face).

c Can only center vectors on main cell for loops 3 to n...and can
c only extrapolate back for loops 2 to n-1.  Must handle other cases
c separately.

c The magnetic field does not require extrapolation to cell centers
c on boundaries since dB/dx = 0 is the boundary condition.  That is
c just copy the interior values to the boundary.
c----------------------------------------------------------------------
CVD$R VECTOR

      !include 'incurv.h'

      real aa(nx,ny,nz,3)        !main cell contravarient vector 
      real bbmf(nx,ny,nz,3)      !main cell contravarient vector
      real cc(nx,ny,nz,3)        !cross product result, main cell
                                 !contravarient (cell face)

      real ax,ay,az,bx,by,bz    !dummy vars
      real temp                 !used to vectorize loop
c      real zfrc(nz)             !0.5*dz_grid(k)/dz_cell(k)
c      real ct(nx,ny,nz,3)       !temp main cell center cross product
      real aac(3),bbc(3)


c extrapolate(/interpolate) to main cell center and do cross product


      call periodic(aa)
      call periodic(bbmf)


c      do 5 k=1,nz
c         zfrc(k) = 0.5*dz_grid(k)/dz_cell(k)
c 5       continue



      do 10 k=2,nz-1      
         do 10 j=2,ny-1
            do 10 i=2,nx-1

               im = i-1         !assume daa/dxyz = 0 at boundary
               jm = j-1         !bbmf is given on boundary
               km = k-1

               ax = 0.5*(aa(i,j,k,1) + aa(im,j,k,1))
               bx = 0.5*(bbmf(i,j,k,1) + bbmf(im,j,k,1))

               ay = 0.5*(aa(i,j,k,2) + aa(i,jm,k,2))
               by = 0.5*(bbmf(i,j,k,2) + bbmf(i,jm,k,2))

               az = zrat(k)*(aa(i,j,k,3) - aa(i,j,km,3)) + aa(i,j,km,3)
               bz = zrat(k)*(bbmf(i,j,k,3) - bbmf(i,j,km,3))
     x                     + bbmf(i,j,km,3)

               ct(i,j,k,1) = ay*bz - az*by
               ct(i,j,k,2) = az*bx - ax*bz
               ct(i,j,k,3) = ax*by - ay*bx

 10            continue

       call periodic(ct)

c extrapolate back to main cell contravarient positions.
c ...just average across cells since cell edges are centered
c about the grid points.
      
      do 60 k=2,nz-1
         do 60 j=2,ny-1
            do 60 i=2,nx-1

               ip = i+1
               jp = j+1
               kp = k+1

               cc(i,j,k,1) = 0.5*(ct(i,j,k,1) + ct(ip,j,k,1))
               cc(i,j,k,2) = 0.5*(ct(i,j,k,2) + ct(i,jp,k,2))
               cc(i,j,k,3) = 0.5*(ct(i,j,k,3) + ct(i,j,kp,3))

 60            continue

      call periodic(cc)


      return
      end SUBROUTINE crossf
c----------------------------------------------------------------------


c----------------------------------------------------------------------
      SUBROUTINE cov_to_contra(bt,btmf)
c Converts total magnetic field from main cell covarient positions
c to main cell contravarient positions.  This is then used in the
c fluid velocity update routines.  This routine assumes that cell 
c edges and cell centers are "topologically centered".  So the grid
c points do not reside at the cell centers...rather they are offset
c a little so that the cell edges are equidistant from the k and k-1
c grid points.  In extrapolating the coventient vectors to the 
c contravarient vector positions, this assymetry is accounted for
c using a linear interpolation of the k and k-1 values to the grid
c point location.
c----------------------------------------------------------------------
CVD$R VECTOR
      !include 'incurv.h'

      real bt(nx,ny,nz,3),   !main cell covarient
     x     btmf(nx,ny,nz,3)  !main cell contravarient

      real bx1, bx2, by1, by2, bz1, bz2  !main cell center fields
c      real zrat           !ratio for doing linear interpolation
                          !to grid point position.
      real zplus, zminus  !position of main cell edges up and down
      real b_j, b_jm, b_i, b_im !intermediate step in average process

      do 10 k=2,nz-1
         do 10 j=2,ny-1
            do 10 i=2,nx-1

               ip = i+1
               jp = j+1
               kp = k+1
               im = i-1
               jm = j-1
               km = k-1

c The x component of B resides at the k and k-1 edges, so this
c requires the non-uniform grid interpolation

c               zplus = (qz(k+1) + qz(k))/2.0
c               zminus = (qz(k) + qz(k-1))/2.0
c               zrat = (qz(k) - zminus)/(zplus - zminus)
   
               b_j = bt(i,j,km,1) 
     x               + zrat(k)*(bt(i,j,k,1) - bt(i,j,km,1)) 
               b_jm = bt(i,jm,km,1)
     x                + zrat(k)*(bt(i,jm,k,1) - bt(i,jm,km,1))
               bx1 = (b_j + b_jm)/2.0

               b_j = bt(ip,j,km,1) 
     x               + zrat(k)*(bt(ip,j,k,1) - bt(ip,j,km,1)) 
               b_jm = bt(ip,jm,km,1)
     x                + zrat(k)*(bt(ip,jm,k,1) - bt(ip,jm,km,1))
               bx2 = (b_j + b_jm)/2.0

               
               b_i = bt(i,j,km,2) 
     x               + zrat(k)*(bt(i,j,k,2) - bt(i,j,km,2)) 
               b_im = bt(im,j,km,2)
     x                + zrat(k)*(bt(im,j,k,2) - bt(im,j,km,2))           
               by1 = (b_i + b_im)/2.0

               b_i = bt(i,jp,km,2) 
     x               + zrat(k)*(bt(i,jp,k,2) - bt(i,jp,km,2)) 
               b_im = bt(im,jp,km,2)
     x                + zrat(k)*(bt(im,jp,k,2) - bt(im,jp,km,2))
               by2 = (b_i + b_im)/2.0


               bz1 = 0.25*(bt(i,j,k,3) + bt(i,jm,k,3) +
     x                     bt(im,jm,k,3) + bt(im,j,k,3))
               bz2 = 0.25*(bt(i,j,kp,3) + bt(i,jm,kp,3) +
     x                     bt(im,jm,kp,3) + bt(im,j,kp,3))

               btmf(i,j,k,1) = 0.5*(bx1+bx2)
               btmf(i,j,k,2) = 0.5*(by1+by2)
               btmf(i,j,k,3) = 0.5*(bz1+bz2)

 10            continue

c      call boundaries(btmf)
      call periodic(btmf)

      return
      end SUBROUTINE cov_to_contra
c----------------------------------------------------------------------


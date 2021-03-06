      MODULE grid_interp

      USE global
      USE dimensions
      USE boundary

      contains

c----------------------------------------------------------------------
      SUBROUTINE edge_to_center(bt,btc)
c----------------------------------------------------------------------
      real bt(nx,ny,nz,3),   !main cell edge
     x     btc(nx,ny,nz,3)   !main cell center

c      real zrat           !ratio for doing linear interpolation
c                          !to grid point position.
      real zplus, zminus  !position of main cell edges up and down
      real b1,b2


      do 10 k=2,nz-1
         do 10 j=2,ny-1
            do 10 i=2,nx-1

c               ip = i+1
c               jp = j+1
c               kp = k+1
               im = i-1
               jm = j-1
               km = k-1


               b2 = 0.5*(bt(i,j,k,1)+bt(i,jm,k,1))
               b1 = 0.5*(bt(i,j,km,1)+bt(i,jm,km,1))
 
               btc(i,j,k,1) = b1 + zrat(k)*(b2-b1)

               b2 = 0.5*(bt(i,j,k,2)+bt(im,j,k,2))
               b1 = 0.5*(bt(i,j,km,2)+bt(im,j,km,2))
 
               btc(i,j,k,2) = b1 + zrat(k)*(b2-b1)

               btc(i,j,k,3) = 0.25*(bt(i,j,k,3)+bt(im,j,k,3)+ 
     x              bt(im,jm,k,3) + bt(i,jm,k,3))

      
 10         continue

      call periodic(btc)
      
      return
      end SUBROUTINE edge_to_center
c----------------------------------------------------------------------


c----------------------------------------------------------------------
      SUBROUTINE face_to_center(v,vc)
c----------------------------------------------------------------------
      !!include 'incurv.h'

      real v(nx,ny,nz,3)        !vector at contravarient position
      real vc(nx,ny,nz,3)       !vector at cell center
c      real zfrc(nz)             !0.5*dz_grid(k)/dz_cell(k)

c      do 5 k=1,nz
c         zfrc(k) = 0.5*dz_grid(k)/dz_cell(k)
c 5       continue

      call periodic(v)

      do 10 i=2,nx
         do 10 j=2,ny
            do 10 k=2,nz

               im = i-1     
               jm = j-1     
               km = k-1

c               if (im .lt. 1) then im = nx-1
c               if (jm .lt. 1) then jm = ny-1
c               if (km .lt. 1) then km = nz-1

               vc(i,j,k,1) = 0.5*(v(i,j,k,1) + v(im,j,k,1))
               vc(i,j,k,2) = 0.5*(v(i,j,k,2) + v(i,jm,k,2))
               vc(i,j,k,3) = zrat(k)*(v(i,j,k,3) - v(i,j,km,3)) + 
     x                                v(i,j,km,3)
 10            continue

      call periodic(vc)

      return
      end SUBROUTINE face_to_center
c----------------------------------------------------------------------

      end MODULE grid_interp

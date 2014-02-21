F77 = mpif90 -i4 -real-size 32 -O4

FILES =  global.f dimensions.f grid_interp.f maind.f gutsf.f gutsp.f misc.f boundary.f part_init.f initial.f inputs.f chem_rates.f
INCLUDE = incurv.h para.h
OBJECTS = global.o dimensions.o grid_interp.o maind.o gutsf.o gutsp.o misc.o boundary.o part_init.o initial.o inputs.o chem_rates.o

hybrid:	$(OBJECTS) 
	$(F77) -o hybrid $(OBJECTS) 

clean:
	rm *.o hybrid *.out

global.o:global.f $(INCLUDE);$(F77) -c global.f
dimensions.o:dimensions.f $(INCLUDE);$(F77) -c dimensions.f
maind.o:maind.f $(INCLUDE);$(F77) -c maind.f
gutsf.o:gutsf.f $(INCLUDE);$(F77) -c gutsf.f
gutsp.o:gutsp.f $(INCLUDE);$(F77) -c gutsp.f
misc.o:misc.f $(INCLUDE);$(F77) -c misc.f
boundary.o:boundary.f $(INCLUDE);$(F77) -c boundary.f
part_init.o:part_init.f $(INCLUDE);$(F77) -c part_init.f
initial.o:initial.f $(INCLUDE);$(F77) -c initial.f
inputs.o:inputs.f $(INCLUDE);$(F77) -c inputs.f
grid_interp.o:grid_interp.f $(INCLUDE);$(F77) -c grid_interp.f
chem_rates.o:chem_rates.f $(INCLUDE);$(F77) -c chem_rates.f
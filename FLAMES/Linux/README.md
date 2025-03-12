Using a 64 Gb RAM machine (too small = minimap2 won't run) w/ 20Gb for root dir and 50 Gb for storage dir

Set up Linux enviornment in CLI before running R script


```
sudo apt install liblapack-dev libopenblas-dev gfortran libxml2-dev libssl-dev libcurl4-openssl-dev libpng-dev \
libfontconfig1-dev libharfbuzz-dev libfribidi-dev libfreetype6-dev libpng-dev libtiff5-dev libjpeg-dev libmagick++-dev gcc-10. g++-10 gfortran-10


#Update gcc and g++ to at least version 10 so Beachmat can compile 
nano ~/.R/Makevars

#Add the following text
'CC=gcc-10
CXX=g++-10
CXX98=g++-10
CXX11=g++-10
CXX14=g++-10
CXX17=g++-10
FC=gfortran-10
F77=gfortran-10'


Then want to run it on the terminal so add the library path from RStudio
nano ~/.Renviron
#Add the following
R_LIBS_USER="/home/rstudio/R/x86_64-pc-linux-gnu-library/4.4"


Rscript -e ".libPaths()" #Check that it was added
```

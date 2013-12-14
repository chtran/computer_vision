---------------------------------------------------------------------------

AUTHOR

Engin Tola

---------------------------------------------------------------------------

CONTACT

web   : http://cvlab.epfl.ch/~tola
email : engin.tola@epfl.ch

---------------------------------------------------------------------------

LICENCE

Source code is available under the GNU General Public License. In short, if
you distribute a software that uses  DAISY, you have to distribute it under
GPL with  the source code.  Another option  is to contact us  to purchase a
commercial license.

For a copy of the GPL: http://www.gnu.org/copyleft/gpl.html

If you use this code in your research please give a reference to

"A  Fast  Local Descriptor  for  Dense  Matching"  by Engin  Tola,  Vincent
Lepetit, and  Pascal Fua. Computer Vision and  Pattern Recognition, Alaska,
USA, June 2008

---------------------------------------------------------------------------

CONTEXT

DAISY is a local image descriptor designed for dense wide-baseline matching
purposes. For more details about the descriptor please read the paper.

---------------------------------------------------------------------------

SOFTWARE

A. QUICK START
--------------

im = imread('frame.pgm');
dzy = compute_daisy(im);

This will  compute the  descriptors of  every pixel in  the image  'im' and
store them  under 'dzy.descs'.  You can  extract the descriptor  of a point
(y,x) with

out = display_descriptor(dzy,y,x);

In the matrix 'out', each row is a normalized histogram ( by default ).


B. DETAILED DESCRIPTION
-----------------------

The  software is  implemented in  2 stages:  precomputation  and descriptor
computation. Precomputation stage is  implemented entirely on Matlab and is
done by the 'init_daisy' function.  After that, descriptors are computed by
the mex file 'mex_compute_all_descriptors'.

The parameters of the descriptor can be set using

dzy = init_daisy(im, R, RQ, TQ, HQ, SI, LI, NT )

where

R  : radius of the descriptor
RQ : number of rings
TQ : number of histograms on each ring
HQ : number of bins of the histograms

SI : spatial interpolation enable/disable
LI : layered interpolation enable/disable
NT : normalization type:
     0 = No normalization
     1 = Partial Normalization
     2 = Full Normalization
     3 = Sift like normalization

For more information, read the above paper and study the code.

There's also a mex  file for computing a single descriptor but  it is not a
good idea to use it in a for loop within matlab.

I also included matlab functions to compute a descriptor

function dsc=compute_descriptor(dzy, y, x, ori, spatial_int, hist_int, nt)

for  purely matlab  users but  it takes  a very  long time  to  compute the
descriptors of all pixels.

---------------------------------------------------------------------------

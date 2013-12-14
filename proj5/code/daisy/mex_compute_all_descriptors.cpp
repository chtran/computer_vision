/////////////////////////////////////////////////////////////////////////
// This program is free software; you can redistribute it              //
// and/or modify it under the terms of the GNU General Public License  //
// version 2 (or higher) as published by the Free Software Foundation. //
//                                                                     //
// This program is distributed in the hope that it will be useful, but //
// WITHOUT ANY WARRANTY; without even the implied warranty of          //
// MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU   //
// General Public License for more details.                            //
//                                                                     //
// Written and (C) by                                                  //
// Engin Tola                                                          //
//                                                                     //
// web   : http://cvlab.epfl.ch/~tola                                  //
// email : engin.tola@epfl.ch                                          //
//                                                                     //
// If you use this code for research purposes, please refer to the     //
// webpage above                                                       //
/////////////////////////////////////////////////////////////////////////

#include <mex.h>
#include <math.h>
#include <string.h> // Call to memset

#define SIFT_TH 0.154
#define MAX_ITER 5

inline bool clip_vector( float* vec, int sz, float th );

inline void normalize_vector( float* vec, int hs );
inline void normalize_partial( float* desc, int gn, int hs );
inline void normalize_full( float* desc, int sz );
inline void normalize_sift( float* desc, int sz );

inline void u_compute_descriptor_00(const float* H, const float* params, const float* grid, float y, float x, float shift, float* desc_out );
inline void u_compute_descriptor_01(const float* H, const float* params, const float* grid, float y, float x, float shift, float* desc_out );
inline void u_compute_descriptor_10(const float* H, const float* params, const float* grid, float y, float x, float shift, float* desc_out );
inline void u_compute_descriptor_11(const float* H, const float* params, const float* grid, float y, float x, float shift, float* desc_out );

inline void compute_descriptor( const float* H, const float* params, const float* grid, float y, float x, float shift, float* desc_out );

// desc = mexfunc( H, params, grid, coords )
void mexFunction(int nlhs, mxArray *plhs[], int nrhs, const mxArray *prhs[])
{
  if (nrhs != 5) {  printf("in nrhs != 5\n"); return; }
  if (mxGetClassID(prhs[0]) != mxSINGLE_CLASS) { printf("input 1 must be a single array\n"); return; } // H
  if (mxGetClassID(prhs[1]) != mxSINGLE_CLASS) { printf("input 2 must be a single array\n"); return; } // params
  if (mxGetClassID(prhs[2]) != mxSINGLE_CLASS) { printf("input 3 must be a single array\n"); return; } // grid
  if (mxGetClassID(prhs[3]) != mxSINGLE_CLASS) { printf("input 4 must be a single array\n"); return; } // ostable
  if (mxGetClassID(prhs[4]) != mxSINGLE_CLASS) { printf("input 5 must be a single array\n"); return; } // orientation
  if (nlhs != 1) { printf("out nlhs != 1\n"); return; }

  // Histograms
  int const num_dims1 = mxGetNumberOfDimensions(prhs[0]);
  int const *dims1    = mxGetDimensions(prhs[0]);
  float const *H     = (float *)mxGetData(prhs[0]);
  int hs = dims1[1];

  // params
  float const *params = (float *)mxGetData(prhs[1]);
  int const nd_params = mxGetNumberOfDimensions(prhs[1]);
  int const *nparams  = mxGetDimensions(prhs[1]);
  int DS = params[0];
#ifdef DEBUG
  printf("----------------------------------------------\n");
  printf("DS : %f\n",params[0] );
  printf("HN : %f\n",params[1] );
  printf("H  : %f\n",params[2] );
  printf("W  : %f\n",params[3] );
  printf("R  : %f\n",params[4] );
  printf("RQ : %f\n",params[5] );
  printf("TQ : %f\n",params[6] );
  printf("HQ : %f\n",params[7] );
  printf("SI : %f\n",params[8] );
  printf("LI : %f\n",params[9] );
  printf("NT : %f\n",params[10] );
  printf("GOR: %f\n",params[11] );
  printf("----------------------------------------------\n");
#endif

  // grid info
  float const *grid = (float *)mxGetData(prhs[2]);
  int const nd_grid = mxGetNumberOfDimensions(prhs[2]);
  int const *ngrid  = mxGetDimensions(prhs[2]);
  int gn = ngrid[0];

  // ostable info
  float const *ostable = (float *)mxGetData(prhs[3]);

  // orienation
  float const *ori = (float *)mxGetData(prhs[4]);
  if( *ori < 0 || *ori > 360 ) {
     printf("orientation %f must be [0,360)\n",*ori);
     return;
  }

  float shift = ostable[ (int)*ori ];

  // output
   int h=params[2];
   int w=params[3];
   int hw = h*w;
   int odim[] = {DS, hw};
  plhs[0] = mxCreateNumericArray(2, odim, mxSINGLE_CLASS, mxREAL);
  float *desc_out  = (float *)mxGetData(plhs[0]);

  memset( desc_out, 0, sizeof(float)*DS*hw );
  for( int y=0; y<h; y++ )
  {
     // if( y%20 == 0 ) printf("%d/%d completed\n",y,h);
     for( int x=0; x<w; x++ )
     {
        compute_descriptor(H, params, grid, y, x, shift, desc_out+(y*w+x)*DS );
     }
  }
}

inline void compute_descriptor( const float* H, const float* params, const float* grid, float y, float x, float shift, float* desc_out )
{
   int si = params[8];
   int li = params[9];
   int nt = params[10];

   if     ( si == 0 && li == 0 ) u_compute_descriptor_00(H,params,grid,y,x,shift,desc_out);
   else if( si == 0 && li == 1 ) u_compute_descriptor_01(H,params,grid,y,x,shift,desc_out);
   else if( si == 1 && li == 0 ) u_compute_descriptor_10(H,params,grid,y,x,shift,desc_out);
   else if( si == 1 && li == 1 ) u_compute_descriptor_11(H,params,grid,y,x,shift,desc_out);

   if( nt == 0 ) return;
   else if( nt == 1 ) normalize_partial(desc_out, params[1], params[7]);
   else if( nt == 2 ) normalize_full(desc_out, params[0] );
   else if( nt == 3 ) normalize_sift(desc_out, params[0] );
   else printf("\nunknown normalization\n");
}

inline void normalize_vector( float* hist, int hs )
{
   float s=0;
   for( int i=0; i<hs; i++ ) s+= hist[i]*hist[i];
   if( s!=0 ) {
      s = sqrt(s);
      for( int i=0; i<hs; i++ ) hist[i]/=s;
   }
}
inline void normalize_partial( float* desc, int gn, int hs )
{
   for( int g=0; g<gn; g++ )
      normalize_vector( desc+g*hs, hs );
}
inline void normalize_full( float* desc, int sz )
{
   normalize_vector(desc,sz);
}
inline bool clip_vector( float* vec, int sz, float th )
{
   bool retval=false;
   for( int i=0; i<sz; i++ )
      if( vec[i] > th ) {
         vec[i]=th;
         retval = true;
      }
   return retval;
}
inline void normalize_sift( float* desc, int sz )
{
   int iter=0;
   bool change=true;
   while( iter<MAX_ITER && change )
   {
      normalize_vector(desc,sz);
      change = clip_vector(desc,sz,SIFT_TH);
      iter++;
   }
}

inline void u_compute_descriptor_00(const float* H, const float* params, const float* grid, float y, float x, float shift, float* desc_out )
{
   int h=params[2];
   int w=params[3];
   int hw = h*w;
   int hq = params[7];
   int id, g, c, j;
   float* hist;
   const float* cube=0;
   int yy, xx, cnt;
   int hn = params[1];
   int ishift = (int)shift;
   for( g=0; g<hn; g++ )
   {
      c  = grid[g];
      yy = floor(y + grid[g+  hn]);
      xx = floor(x + grid[g+2*hn]);
      if( 0 > yy || yy >= h || 0>xx || xx >= w ) continue;

      id = yy*w+xx;
      cube = H+(c-1)*hw*hq+id;

      hist = desc_out + g*hq;

      for( j=0; j<hq-ishift; j++ )
         hist[j] = cube[(j+ishift)*hw];
      for( cnt=0; cnt<ishift; cnt++,j++ )
         hist[j] = cube[cnt*hw];
   }
}
inline void u_compute_descriptor_01(const float* H, const float* params, const float* grid, float y, float x, float shift, float* desc_out )
{
   int h=params[2];
   int w=params[3];
   int hw = h*w;
   int hq = params[7];
   int id, g, c, j;
   float* hist;
   const float* cube=0;
   int yy, xx, cnt;
   int hn = params[1];
   int ishift = (int)shift;
   float f = shift - ishift;
   for( g=0; g<hn; g++ )
   {
      c  = grid[g];
      yy = floor(y + grid[g+  hn]);
      xx = floor(x + grid[g+2*hn]);
      if( 0 > yy || yy >= h || 0>xx || xx >= w ) continue;

      id = yy*w+xx;
      cube = H+(c-1)*hw*hq+id;

      hist = desc_out + g*hq;

      for( j=0; j<hq-ishift; j++ ) hist[j] = cube[(j+ishift)*hw];
      for( cnt=0; cnt<ishift; cnt++,j++ ) hist[j] = cube[cnt*hw];

      float tmp = hist[0];
      for( cnt=0; cnt<hq-1; cnt++ )
         hist[cnt] = f*hist[cnt+1]+(1-f)*hist[cnt];
      hist[hq-1] = f*tmp+(1-f)*hist[hq-1];
   }
}
inline void u_compute_descriptor_10(const float* H, const float* params, const float* grid, float y, float x, float shift, float* desc_out )
{
   int h=params[2];
   int w=params[3];
   int hw = h*w;
   int hq = params[7];
   int g, c, j;
   float* hist;
   const float* cube=0;
   float yy, xx;
   int iy, ix;
   int cnt;
   int hn = params[1];
   int ishift = (int)shift;
   for( g=0; g<hn; g++ )
   {
      c  = grid[g];
      yy = y + grid[g+  hn];
      xx = x + grid[g+2*hn];
      iy = (int)yy;
      ix = (int)xx;
      if( 0 > iy || iy >= h-1 || 0>ix || ix >= w-1 ) continue;

      float b = yy-iy;
      float a = xx-ix;

      hist = desc_out + g*hq;

      // A C
      // B D

      // A
      cube = H+(c-1)*hw*hq+iy*w+ix;
      for( j=0;     j<hq-ishift; j++    ) hist[j] = (1-a)*(1-b)*cube[(j+ishift)*hw];
      for( cnt=0; cnt<ishift; cnt++,j++ ) hist[j] = (1-a)*(1-b)*cube[cnt*hw];

      // B
      cube = H+(c-1)*hw*hq+iy*w+ix+w;
      for( j=0;     j<hq-ishift; j++    ) hist[j] += b*(1-a)*cube[(j+ishift)*hw];
      for( cnt=0; cnt<ishift; cnt++,j++ ) hist[j] += b*(1-a)*cube[cnt*hw];

      // C
      cube = H+(c-1)*hw*hq+iy*w+ix+1;
      for( j=0;     j<hq-ishift; j++    ) hist[j] += a*(1-b)*cube[(j+ishift)*hw];
      for( cnt=0; cnt<ishift; cnt++,j++ ) hist[j] += a*(1-b)*cube[cnt*hw];

      // D
      cube = H+(c-1)*hw*hq+iy*w+ix+w+1;
      for( j=0;     j<hq-ishift; j++    ) hist[j] += a*b*cube[(j+ishift)*hw];
      for( cnt=0; cnt<ishift; cnt++,j++ ) hist[j] += a*b*cube[cnt*hw];
   }
}
inline void u_compute_descriptor_11(const float* H, const float* params, const float* grid, float y, float x, float shift, float* desc_out )
{
   int h=params[2];
   int w=params[3];
   int hw = h*w;
   int hq = params[7];
   int g, c, j;
   float* hist;
   const float* cube=0;
   float yy, xx;
   int iy, ix;
   int cnt;
   int hn = params[1];
   int ishift = (int)shift;
   float f=shift-ishift;
   for( g=0; g<hn; g++ )
   {
      c  = grid[g];
      yy = y + grid[g+  hn];
      xx = x + grid[g+2*hn];
      iy = (int)yy;
      ix = (int)xx;
      if( 0 > iy || iy >= h-1 || 0>ix || ix >= w-1 ) continue;

      float b = yy-iy;
      float a = xx-ix;

      hist = desc_out + g*hq;

      // A C
      // B D

      // A
      cube = H+(c-1)*hw*hq+iy*w+ix;
      for( j=0;     j<hq-ishift; j++    ) hist[j] = (1-a)*(1-b)*cube[(j+ishift)*hw];
      for( cnt=0; cnt<ishift; cnt++,j++ ) hist[j] = (1-a)*(1-b)*cube[cnt*hw];

      // B
      cube = H+(c-1)*hw*hq+iy*w+ix+w;
      for( j=0;     j<hq-ishift; j++    ) hist[j] += b*(1-a)*cube[(j+ishift)*hw];
      for( cnt=0; cnt<ishift; cnt++,j++ ) hist[j] += b*(1-a)*cube[cnt*hw];

      // C
      cube = H+(c-1)*hw*hq+iy*w+ix+1;
      for( j=0;     j<hq-ishift; j++    ) hist[j] += a*(1-b)*cube[(j+ishift)*hw];
      for( cnt=0; cnt<ishift; cnt++,j++ ) hist[j] += a*(1-b)*cube[cnt*hw];

      // D
      cube = H+(c-1)*hw*hq+iy*w+ix+w+1;
      for( j=0;     j<hq-ishift; j++    ) hist[j] += a*b*cube[(j+ishift)*hw];
      for( cnt=0; cnt<ishift; cnt++,j++ ) hist[j] += a*b*cube[cnt*hw];

      float tmp = hist[0];
      for( cnt=0; cnt<hq-1; cnt++ )
         hist[cnt] = f*hist[cnt+1]+(1-f)*hist[cnt];
      hist[hq-1] = f*tmp+(1-f)*hist[hq-1];
   }
}


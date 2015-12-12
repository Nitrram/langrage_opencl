__constant sampler_t sampler = CLK_NORMALIZED_COORDS_FALSE |CLK_ADDRESS_CLAMP_TO_EDGE | CLK_FILTER_NEAREST;


float langrage_x(float var, __global float4 *ar, int density) {

  int i,j;
  float li = 1;
  float ln = 0;

  for(i=0; i<density; i++){
    for(j=0; j<density; j++){
      if(i!=j){
  	  li *= (var - ar[j].x) / (ar[i].x - ar[j].x);
      }
    }
    ln += li*ar[i].z;
    li = 1;
  }

  return ln;  
}


float langrage_y(float var, __local float4 *ar, int density) {

  int i,j;
  float li = 1;
  float ln = 0;

  for(i=0; i<density; i++){
    for(j=0; j<density; j++){
      if(i!=j){
	li *= (var - ar[j].y) / (ar[i].y - ar[j].y);
      }
    }
    ln += li*ar[i].z;
    li = 1;
  }

  return ln;  
}


__kernel void gen_texture(__global uchar4 *dst_buf, __global float4 *src_buf, int dens, __local float4 *temps) {

  int x = get_global_id(0);
  int y = get_global_id(1);

  
  for(int idx=0; idx<dens; idx++){    
    temps[idx] = (float4)(x, src_buf[idx*dens].y, langrage_x(x, src_buf+(idx*dens), dens), 0.0);
  }


  /*
    x, y
    net[idx][0].y ~ src_buf[idx*dens + 0].y
    net[idx] ~ src_buf+(idx*dens)
   */

  barrier(CLK_LOCAL_MEM_FENCE);
  
  int z = langrage_y(y, temps, dens);
     
  /* z ~ [R|G|B] */
  dst_buf[x*y] = (uchar4)(50,25,50,0);  
}


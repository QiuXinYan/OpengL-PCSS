#define BLOCKER_SEARCH_NUM_SAMPLES 16
#define PCF_NUM_SAMPLES 16
#define NEAR_PLANE 9.5
#define LIGHT_WORLD_SIZE .5
#define LIGHT_FRUSTUM_WIDTH 3.75 #define LIGHT_SIZE_UV (LIGHT_WORLD_SIZE / LIGHT_FRUSTUM_WIDTH) float PenumbraSize(float zReceiver, float zBlocker) //Parallel plane estimation
{
  return (zReceiver - zBlocker) / zBlocker;
} vec2 poissonDisk[16] = {
	 vec2( -0.94201624, -0.39906216 ),
	 vec2( 0.94558609, -0.76890725 ),
	 vec2( -0.094184101, -0.92938870 ),
	 vec2( 0.34495938, 0.29387760 ),
	 vec2( -0.91588581, 0.45771432 ),
	 vec2( -0.81544232, -0.87912464 ),
	 vec2( -0.38277543, 0.27676845 ),
	 vec2( 0.97484398, 0.75648379 ),
	 vec2( 0.44323325, -0.97511554 ),
	 vec2( 0.53742981, -0.47373420 ),
	 vec2( -0.26496911, -0.41893023 ),
	 vec2( 0.79197514, 0.19090188 ),
	 vec2( -0.24188840, 0.99706507 ),
	 vec2( -0.81409955, 0.91437590 ),
	 vec2( 0.19984126, 0.78641367 ),
	 vec2( 0.14383161, -0.14100790 )
};void FindBlocker(
	out float avgBlockerDepth, 
	out float numBlockers, 
	vec2 uv, 
	float zReceiver,
	sampler2D PointSampler
	)
{
	 //This uses similar triangles to compute what
	 //area of the shadow map we should search
	 float searchWidth = LIGHT_SIZE_UV * (zReceiver - NEAR_PLANE) / zReceiver;
	 float blockerSum = 0;
	 numBlockers = 0;
	 for( int i = 0; i < BLOCKER_SEARCH_NUM_SAMPLES; ++i )
	 {
		 float shadowMapDepth = texture(PointSampler, uv + poissonDisk[i] * searchWidth).r;
		 //float shadowMapDepth = tDepthMap.SampleLevel(
		 //PointSampler,
		 //uv + poissonDisk[i] * searchWidth,
		 //0);
		 if ( shadowMapDepth < zReceiver ) {
		 blockerSum += shadowMapDepth;
		 numBlockers++;
		 }
	  }
	 avgBlockerDepth = blockerSum / numBlockers;
} uniform sampler2D tDepthMap;float PCF_Filter( 
	vec2 uv, 
	float zReceiver, 
	float filterRadiusUV,
	sampler2D PCF_Sampler)
{
	 float sum = 0.0f;
	 for ( int i = 0; i < PCF_NUM_SAMPLES; ++i )
	 {
	 vec2 offset = poissonDisk[i] * filterRadiusUV;
	 //float pcfDepth = texture(shadowMap, projCoords.xy + vec2(x, y) * texelSize).r; 
     //shadow += currentDepth - bias > pcfDepth  ? 1.0 : 0.0;  
	 float pcfDepth = texture(PCF_Sampler, uv + offset).r;

	 //sum += tDepthMap.SampleCmpLevelZero(PCF_Sampler, uv + offset, zReceiver);
	 }
	 return sum / PCF_NUM_SAMPLES;
}



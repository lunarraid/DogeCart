/**
 * Copyright (c) 2008 David Wilhelm
 * http://www.dafishinsea.com/blog/2008/09/06/perlin-noise-1-dimensional/
 * MIT license: http://www.opensource.org/licenses/mit-license.php
 * www.opensource.org/licenses/mit-license.php
 * Modified 2011 by Raymond Cook
 */

package com.lunarraid.util
{
    public class PerlinNoise
    {
        public static function getPerlinNoise_1D(seed:uint, len:int=200, octaves:int=8, decay:Number=1):Vector.<Number>
        {
            var graph:Vector.<Number>;
            
            var totalGraph:Vector.<Number> = getNoiseFunctionResults(seed, len, 1, 1);
            var totalAmplitude:Number= 1;
            
            for(var o:int = 1; o <= octaves; o++)
            {
                if(Math.pow(2,o) < len)
                {
                    seed = getNumberFromSeed(seed);
                    graph = getNoiseFunctionResults(seed, len, Math.pow(decay,o), Math.pow(2,o));
                    totalAmplitude+=Math.pow(decay,o);
                    
                    for(var g:int = 0; g < graph.length; g++)
                    {
                        totalGraph[g] += graph[g]; 
                    }
                }
            }
            
            for(var i:int = 0; i < totalGraph.length; i++)
            {
                totalGraph[i] = totalGraph[i]/totalAmplitude;
            }
            
            return totalGraph;
        }
        
        private static function getNoiseFunctionResults(seed:uint, len:int=200, amplitude:Number=1, freq:int=1):Vector.<Number>
        {
            var result:Number = 0; 
            var wavelength:int = int( len/freq );
            var results:Vector.<Number> = [];
            var nextseed:uint = getNumberFromSeed(seed);
            
            for(var x:int = 0; x < len; x++)
            {
                if(x % wavelength == 0)
                {
                    seed  = nextseed;
                    nextseed = getNumberFromSeed(seed);  
                    result = ( seed / 0x7FFFFFFF ) * amplitude - amplitude * 0.5;
                }
                else
                {
                    result = (interpolate(seed, nextseed, (x % wavelength)/wavelength)/0x7FFFFFFF)*amplitude - amplitude/2;
                }
                results.push(result);
            }
            return results; 
        }
        
        public static function getNumberFromSeed(seed:uint):uint
        {
            var lo:uint = 16807 * (seed & 0xffff);
            var hi:uint = 16807 * (seed >> 16);
            
            lo |= (hi & 0x7fff) << 16;
            hi |= hi >> 15;
            
            lo = (lo & 0x7FFFFFFF) | (lo >> 31);
            
            return lo;
        }
        
        private static function interpolate(a:uint,b:uint,i:Number):Number
        {
            var ft:Number = i*Math.PI;
            var f:Number = (1 - Math.cos(ft)) * .5;
            return a*(1-f) + b*f;
        }
    }
}
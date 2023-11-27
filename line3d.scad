/**
* line3d.scad
*
* @copyright Justin Lin, 2017
* @license https://opensource.org/licenses/lgpl-3.0.html
*
* @see https://openhome.cc/eGossip/OpenSCAD/lib3x-line3d.html
*

    p1 : 3 element vector [x, y, z].
    p2 : 3 element vector [x, y, z].
    diameter : The line diameter. Default to 1.
    p1Style : The end-cap style of the point p1. The value must be "CAP_BUTT", "CAP_CIRCLE" or "CAP_SPHERE". The default value is "CAP_CIRCLE".
    p2Style : The end-cap style of the point p2. The value must be "CAP_BUTT", "CAP_CIRCLE" or "CAP_SPHERE". The default value is "CAP_CIRCLE".
    $fa, $fs, $fn : Used by the circle or sphere module internally. Check the circle module or the sphere module for more details. The final fragments of a circle will be a multiple of 4 to fit edges.

**/

line3d([0,1,0],[0,1,2],1,p1Style="CAP_BUTT",$fn = 24); 
line3d([0,0,0],[0,0,2],1,p1Style="CAP_CIRCLE",$fn = 24);
line3d([0,-1,0],[0,-1,2],1,p1Style="CAP_SPHERE",$fn = 24);
line3d([0,-2,0],[0,-2,2],1,p1Style="CAP_BUTT",$fn = 6);

module line3d(p1, p2, diameter = 1, p1Style = "CAP_CIRCLE", p2Style = "CAP_CIRCLE") {
    r = diameter / 2;

    frags = __nearest_multiple_of_4(__frags(r));
    half_fa = 180 / frags;
    
    v = p2 - p1;
    length = norm(v);
    ay = 90 - atan2(v.z, norm([v.x, v.y]));
    az = atan2(v.y, v.x);

    angles = [0, ay, az];

    module cap_with(p) { 
        translate(p) 
        rotate(angles) 
            children();  
    } 

    module cap_butt() {
        cap_with(p1)                 
        linear_extrude(length) 
            circle(r, $fn = frags);
        
        // hook for testing
        test_line3d_butt(p1, r, frags, length, angles);
    }

    module cap(p, style) {
        if(style == "CAP_CIRCLE") {
            cap_leng = r / 1.414;
            cap_with(p) 
            linear_extrude(cap_leng * 2, center = true) 
                circle(r, $fn = frags);

            // hook for testing
            test_line3d_cap(p, r, frags, cap_leng, angles);
        } else if(style == "CAP_SPHERE") { 
            cap_leng = r / cos(half_fa);
            cap_with(p)
                sphere(cap_leng, $fn = frags);  
            
            // hook for testing
            test_line3d_cap(p, r, frags, cap_leng, angles);
        }            
    }


    cap_butt();
    cap(p1, p1Style);
    cap(p2, p2Style);
}

// Override them to test
module test_line3d_butt(p, r, frags, length, angles) {

}

module test_line3d_cap(p, r, frags, cap_leng, angles) {
    
}

function __frags(radius) = 
    $fn == 0 ?  
        max(min(360 / $fa, radius * 6.283185307179586 / $fs), 5) :
        max($fn, 3);
        
function __nearest_multiple_of_4(n) =
    let(remain = n % 4)
    remain > 1 ? n - remain + 4 : n - remain;
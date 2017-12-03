//Copyright (c) 2017 Corwin Hansen
//makes a button cell battery box. CR-2016 with pla 3d printing by default. can be used for other battery by changing the setting.

//variables
height=1.6;//button cell height 
diameter=20;//diameter of button cell 
number=50;//number of button cell per stack
stack=2;//number of stack connected together

width_tolerance=0.5;//tolerance of width from battery to wall
bottom_endcap_height=3;//height of bottom endcap 
screw_height=5;//height of screw
thumbturn_height=5;//height of thumbturn
thumbturn_knurl=16;//number of knurl on thumbturn divided by 4

wall_width=2;//width of wall
spring_contact_length=5;//length of positive and negative contacts added. set to 0 or negative for applying pressure with screw
contact_wire_diameter=3;//diameter of the contact wire

screw_turn=0.5;//number of turns in screw per unit
screw_tolerance=0.25;//tolerance of screw

shrinkage=0.02;//shrinkage during manifacturing

$fn=50;//smoothness




//module to make a knurl centerd at origin. makes a knurled cilynder with diameter of diameter on edges, height of height, and number*4 bumps
module knurl(diameter, height, number) {
      union(){
        for(n=[1:number]){
            rotate([0,0,(360*n)/(number*4)]){
               cube(size = [diameter/sqrt(2),diameter/sqrt(2),height], center = true);
            } 
        }
    }
}



//module for making a thread. makes a threadded rod with height of height, inner diameter of din, outer diameter of dout, and has turn turns per unit
module thread(height, turn, din, dout){
    linear_extrude(height=height, center=false, convexity=10, twist=-360*turn*height){//extrude while turning to get the thread
        translate([(dout-din)/4, 0, 0]){//translate circle to correct position
            circle(d=(dout+din)/2);//make the circle that turns in to screw threads
        }
    }
}


    
//module for making the body. Takes in variables and makes the correct object
module body (height, number, diameter, width_tolerance, bottom_endcap_height, screw_height, thumbturn_height, thumbturn_knurl, wall_width, spring_contact_length, contact_wire_diameter , screw_turn, screw_tolerance){
    //calculations
    dout=diameter+width_tolerance*2+wall_width*2;//calculate the outer diameter
    din=diameter+width_tolerance*2;//calculate the inner diameter
    theight=height*number+bottom_endcap_height+screw_height+spring_contact_length;//calculate total height of the body
    difference(){//subtract inner cylinder, wire hole, and screw from outer cylinder
        
        cylinder(h=theight, d=dout);//make outer cylinder
        
        translate([0, 0, bottom_endcap_height]){//move inner cylinder up to accomodate for bottom
            cylinder(h=theight, d=din);//make inner cylinder
        }
        
        translate([0, 0, -bottom_endcap_height/2]){//move wire cylinder so boolean happens correctly
            cylinder(h=bottom_endcap_height*2, d=contact_wire_diameter);//make cylinder for wire
        }
        
        translate([0, 0, theight-screw_height-thumbturn_height/4]){//move threadded rod to correct position
            thread(height=screw_height+thumbturn_height/2, turn=screw_turn, din=din, dout=(dout+din)/2);//make threadded rod
        }
    }
}



//module for making the cap. variables same as defined on top
//size is the knurl diameter
module cap (diameter, width_tolerance, bottom_endcap_height, screw_height, thumbturn_height, thumbturn_knurl, wall_width,contact_wire_diameter, screw_turn, screw_tolerance, size){
    //calculations
    dout=diameter+width_tolerance*2+wall_width*2;//calculate the outer diameter
    din=diameter+width_tolerance*2;//calculate the inner diameter
        
    difference(){//subtract wire hole from cap
        union(){//add knurl and screw to make screw
            
            translate([0, 0, thumbturn_height/2]){//move threadded rod to correct position
                knurl(diameter=size, height=thumbturn_height, number=thumbturn_knurl);//make knurl for cap    
            }
            
            translate([0, 0, thumbturn_height]){//move threadded rod to correct position
                thread(height=screw_height+thumbturn_height/126, turn=screw_turn, din=din-screw_tolerance*2, dout=(dout+din)/2-screw_tolerance*2);//make threadded rod
            }
            
        }
        
        translate([0, 0, -(thumbturn_height+screw_height)/2]){//move wire cylinder so boolean happens correctly
            cylinder(h=(thumbturn_height+screw_height)*2, d=contact_wire_diameter);//make cylinder for wire
        }    
    }
}



//module for making the body and cap that is specified. variables are the same as defined on the top.
module batterypack (height, number, diameter, stack, width_tolerance, bottom_endcap_height, screw_height, thumbturn_height, thumbturn_knurl, wall_width, spring_contact_length, contact_wire_diameter , screw_turn, screw_tolerance, shrinkage){
    scale=1/(1-shrinkage);//output scale of the object. Calculated based on shrinkage.
    //calculations
    dout=diameter+width_tolerance*2+wall_width*2;//calculate the outer diameter
    din=diameter+width_tolerance*2;//calculate the inner diameter
    
    scale(scale){//scale the object
        
        for(n=[1:stack]){//arrange caps
            translate([0, (n-1)*(dout+wall_width), 0]) {
                if(stack == 1){
                    cap(diameter, width_tolerance, bottom_endcap_height, screw_height, thumbturn_height, thumbturn_knurl, wall_width,contact_wire_diameter, screw_turn, screw_tolerance, size = dout);//make bigger cap if possible
                }
                else{
                     cap(diameter, width_tolerance, bottom_endcap_height, screw_height, thumbturn_height, thumbturn_knurl, wall_width,contact_wire_diameter, screw_turn, screw_tolerance, size = (dout+din)/2);//make smaller cap
                }
            }
        }
        for(n=[1:stack]){//arrange bodies
            translate([dout+wall_width, (n-1)*((dout+din+wall_width)/2), 0]) {
                body(height, number, diameter, width_tolerance, bottom_endcap_height, screw_height, thumbturn_height, thumbturn_knurl, wall_width, spring_contact_length, contact_wire_diameter , screw_turn, screw_tolerance);//make body
            }
        }
    }
}




//make the actual thing
batterypack(height, number, diameter, stack, width_tolerance, bottom_endcap_height, screw_height, thumbturn_height, thumbturn_knurl, wall_width, spring_contact_length, contact_wire_diameter , screw_turn, screw_tolerance, shrinkage);
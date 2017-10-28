//Copyright (c) 2017 Corwin Hansen
//makes a button cell battery box. CR-2016 default

what_to_make=0; //set to 0 for making body, set to 1 for making cap

//variables
height=1.6;//button cell height in 
number=33;//number of button cell
diameter=20;//diameter of button cell in 

width_torarence=0.5;//torarence of width from battery to wall
bottom_endcap_height=3;//height of bottom endcap 
screw_height=5;//height of screw
thumbturn_height=5;//height of thumbturn
thumbturn_knurl=10;//number of knurl on thumbturn divided by 4

wall_width=2;//width of wall
spring_contact_length=5;//length of positive and negative contacts added
contact_wire_diameter=1.5;//diameter of the contact wire

screw=1;//number of turns in screw
screw_torarence=0.2;//torarence of screw

shrinkage=0.05;//shrinkage during manifacturing

$fn=100;//smoothness




//calculations
scale=1/(1-shrinkage);//output scale of the object. Calculated based on shrinkage.
dout=diameter+width_torarence*2+wall_width*2;//calculate the outer diameter
din=diameter+width_torarence*2;//calculate the inner diameter
theight=height*number+bottom_endcap_height+screw_height+spring_contact_length;//calculate total height of the body



//module to make a knurl centerd at origin. makes a knurled cilynder with diameter of kdiameter on edges, height of kheight, and knumber*4 bumps
module knurl(kdiameter, kheight, knumber) {
      union(){
        for(n=[1:knumber]){
            rotate([0,0,(360*n)/(knumber*4)]){
               cube(size = [kdiameter/sqrt(2),kdiameter/sqrt(2),kheight], center = true);
            } 
        }
    }
}



//module for making screw
module screw(){
    
}

//start making the actual thing
scale(scale){//scale the object
    //where everything is made
    
    
    if(what_to_make==0){//if choosen to make the body
        
        difference(){//subtract inner cylinder, wire hole, and screw from outer cylinder
            
            cylinder(h=theight, d=dout);//make outer cylinder
            
            translate([0, 0, bottom_endcap_height]){//move inner cylinder up to accomodate for bottom
                cylinder(h=theight, d=din);//make inner cylinder
            }
            
            translate([0, 0, -bottom_endcap_height/2]){//move wire cylinder so boolean happens correctly
                cylinder(h=bottom_endcap_height*2, d=contact_wire_diameter);//make cylinder for wire
            }
            
            screw();//make screw
            
        }
        
    }
    
    
    else if(what_to_make==1){//if choosen to make the cap
        difference(){//subtract wire hole from cap
            union(){//add knurl and screw to make screw
                knurl(kdiameter=dout, kheight=thumbturn_height, knumber=thumbturn_knurl);//make knurl for cap
                screw();//make screw
            }
            translate([0, 0, -(thumbturn_height+screw_height)/2]){//move wire cylinder so boolean happens correctly
                cylinder(h=(thumbturn_height+screw_height)*2, d=contact_wire_diameter);//make cylinder for wire
            }
        }
    }
}
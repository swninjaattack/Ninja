/* Copyright (c) 2007 Scott Lembcke
 * 
 * Permission is hereby granted, free of charge, to any person obtaining a copy
 * of this software and associated documentation files (the "Software"), to deal
 * in the Software without restriction, including without limitation the rights
 * to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
 * copies of the Software, and to permit persons to whom the Software is
 * furnished to do so, subject to the following conditions:
 * 
 * The above copyright notice and this permission notice shall be included in
 * all copies or substantial portions of the Software.
 * 
 * THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
 * IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
 * FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
 * AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
 * LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
 * OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
 * SOFTWARE.
 */
 

#define CP_ALLOW_PRIVATE_ACCESS 1
#import "DebugNode.h"

#include <stdlib.h>
#include <stdio.h>
#include <math.h>
#include <limits.h>
#include <string.h>

#include "OpenGLES/es1/gl.h"

/*
	IMPORTANT - READ ME!
	
	This file sets up a simple interface that the individual demos can use to get
	a Chipmunk space running and draw what's in it. In order to keep the Chipmunk
	examples clean and simple, they contain no graphics code. All drawing is done
	by accessing the Chipmunk structures at a very low level. It is NOT
	recommended to write a game or application this way as it does not scale
	beyond simple shape drawing and is very dependent on implementation details
	about Chipmunk which may change with little to no warning.
*/

#define LINE_COLOR 1.0f, 0.0f, 0.0f

static void
drawPoint(cpVect p)
{
	glVertexPointer(2, GL_FLOAT, 0, &p);
	glDrawArrays(GL_POINTS, 0, 1);
}

static void
drawLine(cpVect a, cpVect b)
{
	cpVect verts[] = {a, b};

	glVertexPointer(2, GL_FLOAT, 0, &verts);
	glDrawArrays(GL_LINES, 0, 2);
}

static const GLfloat circleVAR[] = {
	 0.0000f,  1.0000f,
	 0.2588f,  0.9659f,
	 0.5000f,  0.8660f,
	 0.7071f,  0.7071f,
	 0.8660f,  0.5000f,
	 0.9659f,  0.2588f,
	 1.0000f,  0.0000f,
	 0.9659f, -0.2588f,
	 0.8660f, -0.5000f,
	 0.7071f, -0.7071f,
	 0.5000f, -0.8660f,
	 0.2588f, -0.9659f,
	 0.0000f, -1.0000f,
	-0.2588f, -0.9659f,
	-0.5000f, -0.8660f,
	-0.7071f, -0.7071f,
	-0.8660f, -0.5000f,
	-0.9659f, -0.2588f,
	-1.0000f, -0.0000f,
	-0.9659f,  0.2588f,
	-0.8660f,  0.5000f,
	-0.7071f,  0.7071f,
	-0.5000f,  0.8660f,
	-0.2588f,  0.9659f,
	 0.0000f,  1.0000f,
	 0.0f, 0.0f, // For an extra line to see the rotation.
};
static const int circleVAR_count = sizeof(circleVAR)/sizeof(GLfloat)/2;

static void
drawCircleShape(cpBody *body, cpCircleShape *circle)
{
	glVertexPointer(2, GL_FLOAT, 0, circleVAR);

	glPushMatrix(); {
		cpVect center = circle->tc;
		glTranslatef(center.x, center.y, 0.0f);
		glRotatef(body->a*180.0f/M_PI, 0.0f, 0.0f, 1.0f);
		glScalef(circle->r, circle->r, 1.0f);

		glColor4f(LINE_COLOR, 1.0f);
		glDrawArrays(GL_LINE_STRIP, 0, circleVAR_count);
	} glPopMatrix();
}

static const GLfloat pillVAR[] = {
	 0.0000f,  1.0000f, 1.0f,
	 0.2588f,  0.9659f, 1.0f,
	 0.5000f,  0.8660f, 1.0f,
	 0.7071f,  0.7071f, 1.0f,
	 0.8660f,  0.5000f, 1.0f,
	 0.9659f,  0.2588f, 1.0f,
	 1.0000f,  0.0000f, 1.0f,
	 0.9659f, -0.2588f, 1.0f,
	 0.8660f, -0.5000f, 1.0f,
	 0.7071f, -0.7071f, 1.0f,
	 0.5000f, -0.8660f, 1.0f,
	 0.2588f, -0.9659f, 1.0f,
	 0.0000f, -1.0000f, 1.0f,

	 0.0000f, -1.0000f, 0.0f,
	-0.2588f, -0.9659f, 0.0f,
	-0.5000f, -0.8660f, 0.0f,
	-0.7071f, -0.7071f, 0.0f,
	-0.8660f, -0.5000f, 0.0f,
	-0.9659f, -0.2588f, 0.0f,
	-1.0000f, -0.0000f, 0.0f,
	-0.9659f,  0.2588f, 0.0f,
	-0.8660f,  0.5000f, 0.0f,
	-0.7071f,  0.7071f, 0.0f,
	-0.5000f,  0.8660f, 0.0f,
	-0.2588f,  0.9659f, 0.0f,
	 0.0000f,  1.0000f, 0.0f,
};
static const int pillVAR_count = sizeof(pillVAR)/sizeof(GLfloat)/3;

static void
drawSegmentShape(cpBody *body, cpSegmentShape *seg)
{
	cpVect a = seg->ta;
	cpVect b = seg->tb;

	if(seg->r){
		glVertexPointer(3, GL_FLOAT, 0, pillVAR);
		glPushMatrix(); {
			cpVect d = cpvsub(b, a);
			cpVect r = cpvmult(d, seg->r/cpvlength(d));

			const GLfloat matrix[] = {
				 r.x, r.y, 0.0f, 0.0f,
				-r.y, r.x, 0.0f, 0.0f,
				 d.x, d.y, 0.0f, 0.0f,
				 a.x, a.y, 0.0f, 1.0f,
			};
			glMultMatrixf(matrix);

			glColor4f(LINE_COLOR, 1.0f);
			glDrawArrays(GL_LINE_LOOP, 0, pillVAR_count);
		} glPopMatrix();
	} else {
		glColor4f(LINE_COLOR, 1.0f);
		drawLine(a, b);
	}
}

static void
drawPolyShape(cpBody *body, cpPolyShape *poly)
{
	int count = poly->numVerts;
	glVertexPointer(2, GL_FLOAT, 0, poly->tVerts);

	glColor4f(LINE_COLOR, 1.0f);
	glDrawArrays(GL_LINE_LOOP, 0, count);
}

static void
drawShape(cpShape *shape, void *unused)
{
	cpShapeCacheBB(shape);
	cpBody *body = shape->body;

	switch(shape->klass->type){
		case CP_CIRCLE_SHAPE:
			drawCircleShape(body, (cpCircleShape *)shape);
			break;
		case CP_SEGMENT_SHAPE:
			drawSegmentShape(body, (cpSegmentShape *)shape);
			break;
		case CP_POLY_SHAPE:
			drawPolyShape(body, (cpPolyShape *)shape);
			break;
		default:
			printf("Bad enumeration in drawObject().\n");
	}
}

static const GLfloat springVAR[] = {
	0.00f, 0.0f,
	0.20f, 0.0f,
	0.25f, 3.0f,
	0.30f,-6.0f,
	0.35f, 6.0f,
	0.40f,-6.0f,
	0.45f, 6.0f,
	0.50f,-6.0f,
	0.55f, 6.0f,
	0.60f,-6.0f,
	0.65f, 6.0f,
	0.70f,-3.0f,
	0.75f, 6.0f,
	0.80f, 0.0f,
	1.00f, 0.0f,
};
static const int springVAR_count = sizeof(springVAR)/sizeof(GLfloat)/2;

static void
drawSpring(cpDampedSpring *spring, cpBody *body_a, cpBody *body_b)
{
	cpVect a = cpvadd(body_a->p, cpvrotate(spring->anchr1, body_a->rot));
	cpVect b = cpvadd(body_b->p, cpvrotate(spring->anchr2, body_b->rot));

	glPointSize(3.0f);
	drawPoint(a);
	drawPoint(b);

	cpVect delta = cpvsub(b, a);

	glVertexPointer(2, GL_FLOAT, 0, springVAR);
	glPushMatrix(); {
		GLfloat x = a.x;
		GLfloat y = a.y;
		GLfloat cos = delta.x;
		GLfloat sin = delta.y;
		GLfloat s = 1.0f/cpvlength(delta);

		const GLfloat matrix[] = {
				 cos,    sin, 0.0f, 0.0f,
			-sin*s,  cos*s, 0.0f, 0.0f,
				0.0f,   0.0f, 1.0f, 0.0f,
					 x,      y, 0.0f, 1.0f,
		};

		glMultMatrixf(matrix);
		glDrawArrays(GL_LINE_STRIP, 0, springVAR_count);
	} glPopMatrix();
}

static void
drawConstraint(cpConstraint *constraint, void *unused)
{
	cpBody *body_a = constraint->a;
	cpBody *body_b = constraint->b;

	const cpConstraintClass *klass = constraint->klass;
	if(klass == cpPinJointGetClass()){
		cpPinJoint *joint = (cpPinJoint *)constraint;

		cpVect a = cpvadd(body_a->p, cpvrotate(joint->anchr1, body_a->rot));
		cpVect b = cpvadd(body_b->p, cpvrotate(joint->anchr2, body_b->rot));

		glPointSize(3.0f);
		drawPoint(a);
		drawPoint(b);

		drawLine(a, b);
	} else if(klass == cpSlideJointGetClass()){
		cpSlideJoint *joint = (cpSlideJoint *)constraint;

		cpVect a = cpvadd(body_a->p, cpvrotate(joint->anchr1, body_a->rot));
		cpVect b = cpvadd(body_b->p, cpvrotate(joint->anchr2, body_b->rot));

		glPointSize(3.0f);
		drawPoint(a);
		drawPoint(b);

		drawLine(a, b);
	} else if(klass == cpPivotJointGetClass()){
		cpPivotJoint *joint = (cpPivotJoint *)constraint;

		cpVect a = cpvadd(body_a->p, cpvrotate(joint->anchr1, body_a->rot));
		cpVect b = cpvadd(body_b->p, cpvrotate(joint->anchr2, body_b->rot));

		glPointSize(3.0f);
		drawPoint(a);
		drawPoint(b);
	} else if(klass == cpGrooveJointGetClass()){
		cpGrooveJoint *joint = (cpGrooveJoint *)constraint;

		cpVect a = cpvadd(body_a->p, cpvrotate(joint->grv_a, body_a->rot));
		cpVect b = cpvadd(body_a->p, cpvrotate(joint->grv_b, body_a->rot));
		cpVect c = cpvadd(body_b->p, cpvrotate(joint->anchr2, body_b->rot));

		glPointSize(3.0f);
		drawPoint(c);

		drawLine(a, b);
	} else if(klass == cpDampedSpringGetClass()){
		drawSpring((cpDampedSpring *)constraint, body_a, body_b);
	} else {
//		printf("Cannot draw constraint\n");
	}
}


@interface ChipmunkSpace : NSObject

-(cpSpace *)space;

@end


@implementation ChipmunkDebugNode

-(void) draw;
{
	glDisableClientState(GL_COLOR_ARRAY);
	glDisableClientState(GL_TEXTURE_COORD_ARRAY);
	glDisable(GL_TEXTURE_2D);

	glPushMatrix(); {
		glScalef(CC_CONTENT_SCALE_FACTOR(), CC_CONTENT_SCALE_FACTOR(), 1.0);
		glLineWidth(1.0f);
		cpSpaceEachShape(_spacePtr, drawShape, NULL);

		glColor4f(0.5f, 1.0f, 0.5f, 1.0f);
		cpSpaceEachConstraint(_spacePtr, drawConstraint, NULL);
	} glPopMatrix();

	glEnableClientState(GL_COLOR_ARRAY);
	glEnableClientState(GL_TEXTURE_COORD_ARRAY);
	glEnable(GL_TEXTURE_2D);
}

+ debugNodeForChipmunkSpace:(ChipmunkSpace *)space;
{
	ChipmunkDebugNode *node = [[ChipmunkDebugNode alloc] init];
	node->_spaceObj = [space retain];
	node->_spacePtr = space.space;

	return [node autorelease];
}

+ debugNodeForCPSpace:(cpSpace *)space;
{
	ChipmunkDebugNode *node = [[ChipmunkDebugNode alloc] init];
	node->_spacePtr = space;

	return [node autorelease];
}

- (void) dealloc
{
	[_spaceObj release];
	[super dealloc];
}

@end

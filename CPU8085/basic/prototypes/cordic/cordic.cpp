// cordic.cpp : Defines the entry point for the console application.
//

#include "stdafx.h"
#include "math.h"

const int MaxBits = 32;

const float PI		= 3.141592653589793238f;
const float TwoPi	= 2.0f*PI;
const float HalfPi	= PI/2.0f;

const float E		= 2.718281828459045235f;

struct Reply
{
	float x, y, z;
};

float Alpha[3][MaxBits+1];
float Scale[3];

float Scalb(int k, float x)
{
	return x*powf(2.0f, (float)k);
}

void InitLookup()
{
	float pow2;
	int m, k;
	int next;

	pow2 = 1.0;
	for (k=0; k<=MaxBits; ++k)
	{
		Alpha[2][k] = atanf(pow2);
		Alpha[1][k] = pow2;
		if (k == 0)
		{
			Alpha[0][k] = 0.0f;
		}
		else
		{
			Alpha[0][k] = float(log((1.0+pow2)/(1.0-pow2))/2.0);
		}

		pow2 = pow2/2.0f;
	}

	for(m=-1; m<=1; ++m)
	{
		k = (m==1)?0:1;
		next = 4;
		Scale[m+1] = 1.0;

		do
		{
			Scale[m+1] = Scale[m+1]*sqrtf(1.0f + Scalb(-2*k, float(m)));
			if ((m == -1) && (k == next))
			{
				next = 3*k + 1;
			}
			else
			{
				++k;
			}
		}
		while (k<=MaxBits);
		Scale[m+1] = 1.0f/Scale[m+1];
	}
}

Reply DoCordic(float x, float y, float z, int m, bool reduceAngle)
{
	float	xn, yn, zn;
	int		start, k;
	int		nextK;
	bool	substract;
	Reply	reply;

	start = (m==1)?0:1;
	k = start; nextK = 4;
	do
	{
		if (reduceAngle)
		{
			substract = (y > 0.0);
		}
		else
		{
			substract = (z < 0.0);
		}

		if (substract)
		{
			xn = x + Scalb(-k, float(m)*y);
			yn = y - Scalb(-k, x);
			zn = z + Alpha[m+1][k];
		}
		else
		{
			xn = x - Scalb(-k, float(m)*y);
			yn = y + Scalb(-k, x);
			zn = z - Alpha[m+1][k];
		}

		x = xn; y = yn; z = zn;

		if ((m == -1) && (k == nextK))
		{
			nextK = 3*k + 1;
		}
		else
		{
			++k;
		}

	}
	while(k<=MaxBits);

	reply.x = xn; 
	reply.y = yn; 
	reply.z = zn;

	return reply;
}

void Reduce(float x, float interval, int &multiple, float &delta)
{
	x = fabsf(x);
	if (x >= interval)
	{
		multiple = (int)floorf(x/interval);
		delta = x - float(multiple)*interval;
	}
	else
	{
		multiple = 0;
		delta = x;
	}
}

float Sin(float x)
{
	Reply answer;
	int quadrant;
	float angle;
	float result;

	Reduce(x, HalfPi, quadrant, angle);
	answer = DoCordic(Scale[1 + 1], 0.0, angle, 1, false);
	switch(quadrant % 4)
	{
	case 0: result = answer.y; break;
	case 1: result = answer.x; break;
	case 2: result = -answer.y; break;
	case 3: result = -answer.x; break;
	}

	if (x < 0.0)
	{
		result = -result;
	}

	return result;
}

float Cos(float x)
{
	Reply answer;
	int quadrant;
	float angle;
	float result;

	Reduce(x, HalfPi, quadrant, angle);
	answer = DoCordic(Scale[1 + 1], 0.0, angle, 1, false);
	switch(quadrant % 4)
	{
	case 0: result = answer.x; break;
	case 1: result = -answer.y; break;
	case 2: result = -answer.x; break;
	case 3: result = answer.y; break;
	}

	return result;
}

float Tan(float x)
{
	Reply answer;
	int quadrant;
	float angle;
	float sres, cres;

	Reduce(x, HalfPi, quadrant, angle);
	answer = DoCordic(Scale[1 + 1], 0.0, angle, 1, false);
	switch(quadrant % 4)
	{
	case 0: 
		sres = answer.y; 
		cres = answer.x;
		break;
	case 1:
		sres = answer.x; 
		cres = -answer.y;
		break;
	case 2:
   		sres = -answer.y; 
		cres = -answer.x;
		break;
	case 3:
		sres = -answer.x; 
		cres = answer.y;
		break;
	}

	if (x < 0.0) 
	{
		sres = -sres;
	}

	return sres/cres;
}

float ArcTan(float x)
{
	Reply result;
	result = DoCordic(1.0, x, 0.0, 1, true);
	return result.z;
}

float Ln(float x)
{
	float frac;
	int exp;
	Reply answer;

	if (x <= 0.0)
	{
		return -1E12f;
	}

	exp = 0; frac = x;
	while ((frac < 0.5) || (frac >= 1.0))
	{
		if (frac >= 1.0f)
		{
			frac /= 2.0f;
			++exp;
		}
		else if (frac < 0.5f)
		{
			frac *= 2.0f;
			--exp;
		}
	}

	answer = DoCordic(1.0f+frac, 1.0f-frac, 0.0f, -1, true);
	return -2.0f*answer.z + float(exp)*logf(2.0f);

}

float Exp(float x)
{
	Reply answer;
	int quadrant;
	float delta;
	float result;

	Reduce(x, logf(2.0), quadrant, delta);
	answer = DoCordic(Scale[-1 + 1], 0.0, delta, -1, false);
	result = Scalb(quadrant, answer.y+answer.x);
	if (x < 0.0)
	{
		result = 1.0f/result;
	}

	return result;
}

float Sqrt(float x)
{
	float frac;
	int exp;
	Reply answer;
	float result;

	if (x <= 0.0f)
	{
		return 0.0f;
	}

	exp = 0; frac = x;
	while ((frac < 0.5f) || (frac >= 1.0f))
	{
		if (frac >= 1.0f)
		{
			frac /= 2.0f;
			++exp;
		}
		else if (frac < 0.5)
		{
			frac *= 2.0f;
			--exp;
		}
	}

	if ((exp&1)==1)
	{
		frac /= 2.0f;
	}

	answer = DoCordic(frac+0.25f, frac-0.25f, 0.0, -1, true);

	if ((exp&1)==1)
	{
		result = Scalb((exp+1)/2, answer.x*Scale[-1 + 1]);
	}
	else
	{
		result = Scalb(exp/2, answer.x*Scale[-1 + 1]);
	}

	return result;
}

int main(int argc, char* argv[])
{
	InitLookup();

	//for (float a = 0; a<TwoPi; a+=0.1f)
	//{
	//	fprintf(stderr, "%f\t%f\t%f\t%f\n", a, Sin(a), sinf(a), Sin(a)-sinf(a));
	//}

	//for (float a = 0; a<TwoPi; a+=0.1f)
	//{
	//	fprintf(stderr, "%f\t%f\t%f\t%f\n", a, Cos(a), cosf(a), Cos(a)-cosf(a));
	//}

	//for (float a = -HalfPi+0.05; a<HalfPi; a+=0.05f)
	//{
	//	fprintf(stderr, "%f\t%f\t%f\t%f\n", a, Tan(a), tanf(a), Tan(a)-tanf(a));
	//}

	//for (float a = -10; a<10; a+=0.1f)
	//{
	//	fprintf(stderr, "%f\t%f\t%f\t%f\n", a, ArcTan(a), atanf(a), ArcTan(a)-atanf(a));
	//}

	//for (float a = 0.001; a<0.1; a+=0.001f)
	//{
	//	fprintf(stderr, "%f\t%f\t%f\t%f\n", a, Ln(a), logf(a), Ln(a)-logf(a));
	//}

	//for (float a = -10; a<20; a+=0.5f)
	//{
	//	fprintf(stderr, "%f\t%f\t%f\t%f\n", a, Exp(a), expf(a), Exp(a)-expf(a));
	//}

	for (float a = 0; a<10; a+=0.1)
	{
		fprintf(stderr, "%f\t%f\t%f\t%f\n", a, Sqrt(a), sqrtf(a), Sqrt(a)-sqrtf(a));
	}


	return 0;
}


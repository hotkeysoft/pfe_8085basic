#ifndef __UNTOKENIZE_H_INCLUDED
#define __UNTOKENIZE_H_INCLUDED

#include <iostream>

class untokenize
{
public:
	untokenize(const char *str) : m_str(str) {}

private:
	const char *m_str;

	friend std::ostream operator<< (std::ostream &os, const untokenize &u);
};

std::ostream operator<< (std::ostream &os, const untokenize &u);

#endif
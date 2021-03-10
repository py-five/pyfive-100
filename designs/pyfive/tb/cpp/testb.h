////////////////////////////////////////////////////////////////////////////////
//
// Filename: 	testb.h
//
// Project:	A Set of Wishbone Controlled SPI Flash Controllers
//
// Purpose:	A wrapper for a common interface to a clocked FPGA core
//		begin exercised in Verilator.
//
// Creator:	Dan Gisselquist, Ph.D.
//		Gisselquist Technology, LLC
//
////////////////////////////////////////////////////////////////////////////////
//
// Copyright (C) 2015,2017-2018, Gisselquist Technology, LLC
//
// This file is part of the set of Wishbone controlled SPI flash controllers
// project
//
// The Wishbone SPI flash controller project is free software (firmware):
// you can redistribute it and/or modify it under the terms of the GNU Lesser
// General Public License as published by the Free Software Foundation, either
// version 3 of the License, or (at your option) any later version.
//
// The Wishbone SPI flash controller project is distributed in the hope
// that it will be useful, but WITHOUT ANY WARRANTY; without even the implied
// warranty of MERCHANTIBILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
// GNU Lesser General Public License for more details.
//
// You should have received a copy of the GNU Lesser General Public License
// along with this program.  (It's in the $(ROOT)/doc directory.  Run make
// with no target there if the PDF file isn't present.)  If not, see
// <http://www.gnu.org/licenses/> for a copy.
//
// License:	LGPL, v3, as defined and found on www.gnu.org,
//		http://www.gnu.org/licenses/lgpl.html
//
//
////////////////////////////////////////////////////////////////////////////////
//
//
#ifndef	TESTB_H
#define	TESTB_H

#include <stdio.h>
#include <stdint.h>
#ifdef VCD_TRACE
#include <verilated_vcd_c.h>
#endif // #ifdef VCD_TRACE


template <class VA>	class TESTB {
public:
	VA	*m_core;
#ifdef VCD_TRACE
	VerilatedVcdC*	m_trace;
#endif // #ifdef VCD_TRACE
	unsigned long	m_tickcount;

#ifdef VCD_TRACE
	TESTB(void) : m_trace(NULL), m_tickcount(0l) {
#else // #ifdef VCD_TRACE
	TESTB(void) :  m_tickcount(0l) {
#endif
		m_core = new VA;
#ifdef VCD_TRACE
		Verilated::traceEverOn(true);
#endif
		m_core->clk = 0;
		eval(); // Get our initial values set properly.
	}
	virtual ~TESTB(void) {
#ifdef VCD_TRACE
		if (m_trace) m_trace->close();
#endif
		delete m_core;
		m_core = NULL;
	}

#ifdef VCD_TRACE
	virtual	void	opentrace(const char *vcdname) {
		if (!m_trace) {
			m_trace = new VerilatedVcdC;
                        #ifdef TRACE_LVLV
			   m_core->trace(m_trace, TRACE_LVLV);
                        #else
                            m_core->trace(tfp, 99);  // Trace 99 levels of hierarchy by default
                        #endif // #ifdef TRACE_LVLV
			m_trace->open(vcdname);
		}
	}

	virtual	void	closetrace(void) {
		if (m_trace) {
			m_trace->close();
			m_trace = NULL;
		}
	}

#endif
	virtual	void	eval(void) {
		m_core->eval();
	}

	virtual	void	tick(void) {
		m_tickcount++;

		// Make sure we have our evaluations straight before the top
		// of the clock.  This is necessary since some of the 
		// connection modules may have made changes, for which some
		// logic depends.  This forces that logic to be recalculated
		// before the top of the clock.
		eval();
                #ifdef VCD_TRACE
		   if (m_trace) m_trace->dump(10*m_tickcount-2);
                #endif
		m_core->clk = 1;
		eval();
                #ifdef VCD_TRACE
		   if (m_trace) m_trace->dump(10*m_tickcount);
                #endif
		m_core->clk = 0;
		eval();
                #ifdef VCD_TRACE
		if (m_trace) {
			m_trace->dump(10*m_tickcount+5);
			m_trace->flush();
		}
                #endif
	}

	virtual	void	reset(void) {
	}
};

#endif

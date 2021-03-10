

#include "verilated.h"
#include "Vpyfive_tb_top.h"
#include "qspiflashsim.h"
#include "testb.h"


#define	QSPIFLASH	0x0400000
#define	PARENT	TESTB<Vpyfive_tb_top>

#define STRINGIFY(s) _STRINGIFY(s)
#define _STRINGIFY(s) #s


class	PYFIVE_TB : public PARENT {
	QSPIFLASHSIM	*m_flash;
	bool		m_bomb;
public:

	PYFIVE_TB(void) {
		m_core = new Vpyfive_tb_top;
		m_flash= new QSPIFLASHSIM(24,true);
		m_flash->debug(true);
	}

	unsigned operator[](const int index) { return (*m_flash)[index]; }
	void	setflash(unsigned addr, unsigned v) {
		m_flash->set(addr, v);
	}
	void	load(const char *fname) {
		m_flash->load(0,fname);
	}

	void	set(const unsigned addr, const unsigned val) {
		m_flash->set(addr, val);
	}

	void	tick(void) {
		bool	writeout = false;
		m_core->spim_sdi = (*m_flash)(m_core->spim_csn0, m_core->spim_clk, m_core->spim_sdo);

		PARENT::tick();
	}

	bool	bombed(void) const { return m_bomb; }

};

#define ERASEFLAG	0x80000000
#define DISABLEWP	0x10000000
#define ENABLEWP	0x00000000
#define NPAGES		256
#define SZPAGEB		256
#define SZPAGEW		(SZPAGEB>>2)
#define SECTORSZW	(NPAGES * SZPAGEW)
#define SECTORSZB	(NPAGES * SZPAGEB)
#define	RDBUFSZ		(NPAGES * SZPAGEW)

int main(int  argc, char **argv) {
	Verilated::commandArgs(argc, argv);
	PYFIVE_TB	*tb = new PYFIVE_TB;
	const char	*DEV_RANDOM = "/dev/urandom";
	const char	*FLASH_FILE = "hello.hex";
	unsigned	rdv;
	unsigned	*rdbuf;



        #ifdef VCD_TRACE
            #ifdef VCD_FNAME
               tb->opentrace(STRINGIFY(VCD_FNAME));
            #else
               tb->opentrace("./simx.vcd");
             #endif // #ifdef VCD_FNAME
        #endif // #ifdef VCD_TRACE

	//tb->load(DEV_RANDOM);
	tb->load(FLASH_FILE);
	rdbuf = new unsigned[RDBUFSZ];
	tb->setflash(0,0);

        //while (!Verilated::gotFinish()) {
	for(int i=0; (i<1000)&&(!tb->bombed()); i++) {

	          tb->tick();
        }

	if (tb->bombed())
		goto test_failure;

	printf("VECTOR TEST PASSES!\n");

	for(int i=0; i<8; i++)
		tb->tick();

	printf("SUCCESS!!\n");
        #ifdef VCD_TRACE
             tb->closetrace();
	#endif
	exit(EXIT_FAILURE);
test_failure:
	printf("FAIL-HERE\n");
	for(int i=0; i<8; i++)
		tb->tick();
	printf("TEST FAILED\n");
        #ifdef VCD_TRACE
             tb->closetrace();
	#endif
	exit(EXIT_FAILURE);
}

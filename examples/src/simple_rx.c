


#include <stdio.h>
#include <stdlib.h>
#include <stdint.h>
#include <string.h>
#include <unistd.h>
#include <getopt.h>
#include <signal.h>
#include <errno.h>
#include <ftdi.h>

#define BUFSZ   4096
        
        
static int exitRequested = 0;        
        
static void
sigintHandler(int signum)
{
    fprintf(stderr, "Exit\n");

    exitRequested = 1;
}

int main () 
{
        struct ftdi_context *ftdi;
        char * descstring=NULL;
        int i = 0;
        unsigned char buf[BUFSZ];
        int f;

        fprintf(stderr, "Setup Context\n");
        if((ftdi = ftdi_new()) == 0) {
                fprintf(stderr, "Failed ftdi_new\n");
                return -1;
        }

         
        fprintf(stderr, "Select interface\n");
        if(ftdi_set_interface(ftdi, INTERFACE_A) < 0) {
                fprintf(stderr, "Failed set interface\n");
                return -1;
        }
        

        // First Open port A
        fprintf(stderr, "Open descriptors\n");
        if (ftdi_usb_open_desc(ftdi, 0x0403, 0x6010, descstring, NULL) < 0) {
                fprintf(stderr, "Failed open device descritor: %s\n", ftdi_get_error_string(ftdi) );
                ftdi_free(ftdi);
                return -1;
        }
       
       fprintf(stderr, "Set Bitmode RESET \n");
       if (ftdi_set_bitmode(ftdi, 0xff, BITMODE_RESET) < 0) {
                fprintf(stderr, "Failed Fifo mode\n");
                ftdi_usb_close(ftdi);
                ftdi_free(ftdi);
                return -1; 
       }    

       usleep(100); 
 
       fprintf(stderr, "Set Bitmode SYNFF\n");
       if (ftdi_set_bitmode(ftdi, 0xff, BITMODE_SYNCFF) < 0) {
                fprintf(stderr, "Failed reset mode\n");
                ftdi_usb_close(ftdi);
                ftdi_free(ftdi);
                return -1; 
       }
       
       if (ftdi_set_latency_timer(ftdi, 5) < 0) {
                fprintf(stderr, "Failed reset mode\n");
                ftdi_usb_close(ftdi);
                ftdi_free(ftdi);
                return -1; 
       }

       if (ftdi_setflowctrl(ftdi,SIO_RTS_CTS_HS) < 0) {
                fprintf(stderr, "Failed reset mode\n");
                ftdi_usb_close(ftdi);
                ftdi_free(ftdi);
                return -1; 
       } 

       fprintf(stderr, "Purge Buffers\n");
       if (ftdi_usb_purge_buffers(ftdi) < 0) {
                fprintf(stderr, "Erro purge");
                return -1;
       }
        
       if(ftdi_set_latency_timer(ftdi,2)) {
        fprintf(stderr, "Can't set latency, error %s\n", ftdi_get_error_string(ftdi));
        ftdi_usb_close(ftdi);
        ftdi_free(ftdi);
        return -1;

       }
      
        signal(SIGINT, sigintHandler );


       do {
          for ( i = 0; i < BUFSZ;i++) {
                 buf[i] = (unsigned char) i;
          }
          f = ftdi_write_data(ftdi, buf, BUFSZ);
          if (f < 0) {
                fprintf(stderr, "Data write failure: %s\n", ftdi_get_error_string(ftdi));
          } else {
                fprintf (stderr,"Data written:%d bytes\n", f);
          }
          
       } while( !exitRequested ); 
       
       ftdi_usb_close(ftdi);
       ftdi_free(ftdi);


       return 0;

}

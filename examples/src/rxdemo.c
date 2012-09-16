/* rxdemo.c
 *
 * Test writing to the FT2232H in synchronous FIFO mode.
 *
 * To check for skipped block with appended code, 
 *     a structure as follows is assumed
 *
 * After start, data will be written streaming until the program is aborted
 * Progess information wil be printed out
 * If a filename is given on the command line, the data read from the file will be
 * written to the FT2232H
 *
 */
#include <stdio.h>
#include <stdlib.h>
#include <stdint.h>
#include <string.h>
#include <unistd.h>
#include <getopt.h>
#include <signal.h>
#include <errno.h>
#include <ftdi.h>


static FILE *inputFile;

static int exitRequested = 0;
/*
 * sigintHandler --
 *
 *    SIGINT handler, so we can gracefully exit when the user hits ctrl-C.
 */


static void
sigintHandler(int signum)
{
   exitRequested = 1;
}

static void
usage(const char *argv0)
{
   fprintf(stderr,
           "Usage: %s [options...] \n"
           "Test streaming written to FT2232H\n"
           "[-P string] only look for product with given string\n"
           "-N size of buffer to write\n"
           "If some filename is given, write data read to the FT2232H\n"
           "Progess information is printed each second\n"
           "Abort with ^C\n"
           "\n"
           "Options:\n\n",
           argv0);
   exit(1);
}



int main(int argc, char **argv)
{
   struct ftdi_context *ftdi;
   int c, result, f;
   unsigned char *buf;
   int buflen=-1;
   char const *infile  = 0;
   exitRequested = 0;
   char *descstring = NULL;
   int option_index;
   static struct option long_options[] = {{NULL},};

   while ((c = getopt_long(argc, argv, "P:N:", long_options, &option_index)) !=- 1)
       switch (c) 
       {
       case -1:
           break;
       case 'P':
           descstring = optarg;
           break;
       case 'N':                      
           buflen = (int)strtoul(optarg,NULL,0);
           // Not less than a byte
           if (buflen < 1)
                   buflen = 1;
           // Not to excedd 4kb
           if (buflen > 4096)
                   buflen = 4096;
       default:
           usage(argv[0]);
       }
  
   // Default to 1kb
   if (buflen == -1) {
        //default buffer length
        buflen =1024;
   }

   if (optind == argc - 1)
   {
       // Exactly one extra argument- a dump file
       infile = argv[optind];
   }
   else if (optind < argc)
   {
       // Too many extra args
       usage(argv[0]);
   }
   
   if ((ftdi = ftdi_new()) == 0)
   {
       fprintf(stderr, "ftdi_new failed\n");
       return EXIT_FAILURE;
   }
   
   if (ftdi_set_interface(ftdi, INTERFACE_A) < 0)
   {
       fprintf(stderr, "ftdi_set_interface failed\n");
       ftdi_free(ftdi);
       return EXIT_FAILURE;
   }
   
   if (ftdi_usb_open_desc(ftdi, 0x0403, 0x6010, descstring, NULL) < 0)
   {
       fprintf(stderr,"Can't open ftdi device: %s\n",ftdi_get_error_string(ftdi));
       ftdi_free(ftdi);
       return EXIT_FAILURE;
   }
   
   /* A timeout value of 1 results in may skipped blocks */
   if(ftdi_set_latency_timer(ftdi, 2))
   {
       fprintf(stderr,"Can't set latency, Error %s\n",ftdi_get_error_string(ftdi));
       ftdi_usb_close(ftdi);
       ftdi_free(ftdi);
       return EXIT_FAILURE;
   }
   
  if (infile)
       if ((inputFile = fopen(infile,"rb")) == 0)
           fprintf(stderr,"Can't open input file %s, Error %s\n", infile, strerror(errno));
   
   signal(SIGINT, sigintHandler);
   
   fprintf(stderr, "\nBegin Stream!\n");
   buf = (unsigned char*) malloc (buflen);
   if(buf == NULL) 
   {
        fprintf(stderr, "Could not allocate memory");
        goto closeprogram; 
   }
        
   ftdi_write_data_set_chunksize(ftdi, buflen);

   while(1) {
        result = fread(buf, sizeof(unsigned char), buflen, inputFile);        
        if(result > 0) {
                f =ftdi_write_data(ftdi, buf, result);
                if ( f != result) {
                       fprintf(stderr,"write failed on channel 1 for 0x%x, error %d (%s)\n", f, ftdi_get_error_string(ftdi)); 
                       fprintf(stderr, "Write failed: expected %d, wrote %d\n", result,f); 
                }
                
                printf("%d\n", buf[0]);
        }
        if (result < buflen) {
                fprintf(stderr, "Reached EOF\n");
                break;
        }
        if(exitRequested==1)
                break;
   }
   // write to FT2232H here!
   fprintf(stderr, "\nComplete Stream!\n");
   
closeprogram: 
   if (inputFile) {           
       fclose(inputFile);
       inputFile = NULL;
   }
   fprintf(stderr, "Transmit ended.\n");
   
   if (ftdi_set_bitmode(ftdi,  0xff, BITMODE_RESET) < 0)
   {
       fprintf(stderr,"Can't set synchronous fifo mode, Error %s\n",ftdi_get_error_string(ftdi));
       ftdi_usb_close(ftdi);
       ftdi_free(ftdi);
       return EXIT_FAILURE;
   }
   ftdi_usb_close(ftdi);
   ftdi_free(ftdi);
   signal(SIGINT, SIG_DFL);
      exit (0);
}



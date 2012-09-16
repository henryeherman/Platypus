import argparse
import os
import glob
import zipfile
import logging
import datetime
import sys

logger = logging.getLogger("Gerbs")
hdlr = logging.StreamHandler(sys.stdout)
hdlr.setLevel(logging.DEBUG)
logger.addHandler(hdlr)
logger.setLevel(logging.DEBUG)

suffixes = ['*.G*',
			'*.DRL',
			'*.DRR',
			'*.TXT']
filesToZip = []

parser = argparse.ArgumentParser(description='Zip Gerbs For Production.')
parser.add_argument('--outfile','-o', 
					type=argparse.FileType('w'),
					default='gerbs.zip')

parser.add_argument('--directory','-d', 
					required=False, default=None)

					
def main():
	options=parser.parse_args()
	options.outfile.close()
	
	
	if os.path.exists(options.outfile.name):
		try:
			logger.info("Removing %s..." % options.outfile.name) 
			os.remove(options.outfile.name)
		except:
			parser.error('Could not delete file:%s' % options.outfile.name)

	if options.directory is None:
		dirs = glob.glob("gerb*") or glob.glob("Gerb*")
		for d in dirs:
			if not os.path.isdir(d):
				dirs.remove(d)
		if not dirs:
			parser.error("No gerber* directories found")
		dirs=sorted(dirs, key=lambda d: datetime.datetime.fromtimestamp(os.path.getctime(d)))
		dirs.reverse()
		directory= dirs[0]
		logger.info("Most Recent Gerber Directory '%s'" % dirs[0]) 
		
	else:
		if not os.path.isdir(options.directory):
			parser.error("Not a directory %s" % options.directory)
		
	
	
	with zipfile.ZipFile(options.outfile.name,'w') as gerbzip:
		for suffix in suffixes:
			fs = glob.glob(os.path.join(directory,suffix))
			filesToZip.extend(fs) 
		for f in filesToZip:
			logger.info("Zipping '%s'..." % f)
			gerbzip.write(filename=f,arcname=os.path.basename(f))
			
	logger.info("Finished zipping project files:'%s'" % options.outfile.name )
	
if __name__ == '__main__':
	logger.info('Preparing Gerber Zipfile')
	main()
	logger.handlers=[]

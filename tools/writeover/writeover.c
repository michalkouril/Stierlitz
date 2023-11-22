 /*************************************************************************
 *                                                                        *
 *  This program is free software: you can redistribute it and/or modify  *
 *  it under the terms of the GNU General Public License as published by  *
 *  the Free Software Foundation, either version 3 of the License, or     *
 *  (at your option) any later version.                                   *
 *                                                                        *
 *  This program is distributed in the hope that it will be useful,       *
 *  but WITHOUT ANY WARRANTY; without even the implied warranty of        *
 *  MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the         *
 *  GNU General Public License for more details.                          *
 *                                                                        *
 *  You should have received a copy of the GNU General Public License     *
 *  along with this program.  If not, see <http://www.gnu.org/licenses/>. *
 *                                                                        *
 *************************************************************************/

#include <unistd.h>
#include <stdlib.h>
#include <stdio.h>

#define BLOCKSIZE 512

void printusage(int argc, char *argv[]) {
  printf("Usage: %s -i SRCBINFILE -o DSTBINFILE\n", argv[0]);
}

int main(int argc, char *argv[]) {
  FILE *fp;
  FILE *fpout;
  char c;
  unsigned char block[BLOCKSIZE];

  if (argc != 5) {
    printusage(argc, argv);
    exit(0);
  }

  while ((c = getopt(argc, argv, "i:o:h")) != -1) {
    switch(c) {
    case 'i':
      fp = fopen(optarg, "rb");
      if (fp == NULL) {
	printf("Could not open file: '%s'\n", optarg);
	exit(1);
      }
      printf("Reading file: '%s'\n", optarg);
      break;
    case 'o':
      fpout = fopen(optarg, "r+");
      if (fpout == NULL) {
	printf("Could not open file: '%s'\n", optarg);
	exit(1);
      }
      printf("Writing to file: '%s'\n", optarg);
      break;
    case 'h':
      printusage(argc, argv);
      exit(0);
      break;
    }
  }

  if (fp == NULL || fpout == NULL) {
    printf("Must specify input and output filename!\n");
    exit(1);
  }

  // verify the size of the destination is greater or equal the size of the source
  fseek(fp, 0L, SEEK_END);
  fseek(fpout, 0L, SEEK_END);

  if (ftell(fp) > ftell(fpout)) {
     fprintf(stderr, "Error: Source file is larger than the destination\n");
     fclose(fp);
     fclose(fpout);
     exit(1);
  }

  fseek(fp, 0L, SEEK_SET);
  fseek(fpout, 0L, SEEK_SET);

  while (!feof(fp)) {
    int fp_ret = fread(&block, 1, BLOCKSIZE, fp);
    printf("Transferring %d\n", fp_ret);
    if (fp_ret > 0) {
      fwrite(&block, 1, fp_ret, fpout);
      fflush(fpout);
    } else {
       break;
    }
  }

  fclose(fp);
  fclose(fpout);
  return 0;
}

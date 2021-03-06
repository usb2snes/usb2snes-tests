#include <stdint.h>
#include <string.h>
#include <stdio.h>
#include <stdlib.h>
#include <stdbool.h>
#include <unistd.h>
#include <sys/types.h>
#include <sys/wait.h>


#define MATCH_BYTE(R, E, S) {if ((uint8_t)E != (uint8_t)R) {fprintf(stderr, "%s - Expected : %02X, got : %02X\n", S, (uint8_t) E, (uint8_t) R);return false;}}

#define FAIL(S) {fprintf(stderr, S); return false;}

bool    validate_rom(FILE* fd)
{
    char buffer[10];
    fseek(fd, 0x8000, SEEK_SET);
    fread(&buffer, 1, 4, fd);
    buffer[4] = 0;
    if (strncmp(buffer, "OggS", 4) != 0)
        FAIL("fsf data : Does not start with fsf data\n")
    fseek(fd, 0x57CA6, SEEK_SET);
    fread(&buffer, 1, 1, fd);
    MATCH_BYTE(buffer[0], 0x92, "fsf data : Does not end with the last fsf byte")
    fread(&buffer, 1, 4, fd);
    if (strncmp(buffer, "gOSg", 4) != 0)
        FAIL("Swapped fsf : Does not start with right data\n")
    fseek(fd, 0xA794D, SEEK_SET);
    fread(&buffer, 1, 1, fd);
    MATCH_BYTE(buffer[0], 0x92, "Swapped fsf : Does not end with fsf last byte")
    fread(&buffer, 1, 1, fd);
    MATCH_BYTE(buffer[0], 0x54, "fsf data +5 : Does not start with right byte")
    fseek(fd, 0xF75F4, SEEK_SET);
    fread(&buffer, 1, 1, fd);
    MATCH_BYTE(buffer[0], 0x97, "fsf data +5 : Does not end with right byte")
    fread(&buffer, 1, 1, fd);
    MATCH_BYTE(buffer[0], 0x59, "fsf data xor 22 : Does not start with right byte")
    fseek(fd, 0x14729B, SEEK_SET);
    fread(&buffer, 1, 1, fd);
    MATCH_BYTE(buffer[0], 0x84, "fsf data xor 22 : Does not end with right byte")
    fseek(fd, 0x14729C, SEEK_SET);
    fread(&buffer, 1, 4, fd);
    buffer[4] = 0;
    if (strncmp(buffer, "OggS", 4) != 0)
        FAIL("fsf end filler : Does not start with fsf data\n")
    fseek(fd, 0x196F43, SEEK_SET);
    fread(&buffer, 1, 4, fd);
    buffer[4] = 0;
    if (strncmp(buffer, "OggS", 4) != 0)
        FAIL("fsf 2 end filler : Does not start with fsf data\n")
    fseek(fd, 0x1E6BEA, SEEK_SET);
    fread(&buffer, 1, 4, fd);
    buffer[4] = 0;
    if (strncmp(buffer, "OggS", 4) != 0)
        FAIL("fsf third end filler : Does not start with fsf data\n")
    fseek(fd, 0x1FFFFF, SEEK_SET);
    fread(&buffer, 1, 1, fd);
    MATCH_BYTE(buffer[0], 0x3D, "Final byte")
    return true; 
}

#undef FAIL

int main(int ac, char *ag[])
{
    if (ac != 3)
        return -1;
    FILE* fd = fopen(ag[1], "r+");
    fseek(fd, 0x7FD8, SEEK_SET);
    printf("Setting the sram size to 8kB\n");
    char plop = 4;
    fwrite(&plop, 1, 1, fd);
    fseek(fd, 0x8000, SEEK_SET);
    FILE* fsf = fopen(ag[2], "r");
    char buffer[1024];
    int readed;
    printf("Copying %s to $%X\n", ag[2], (unsigned int) ftell(fd));
    // Copy the file as is
    while (readed = fread(&buffer, 1, 1024, fsf))  
    {
        fwrite(buffer, 1, readed, fd);
    }   
    rewind(fsf);
    
    // Alternate byte
    printf("Copying alternating bytes of %s to $%X\n", ag[2], (unsigned int)ftell(fd));
    while (readed = fread(&buffer, 1, 1024, fsf))  
    {
        for (int i = 0; i < readed; i+=2)
        {
            if (i + 1 >= readed)
                break;
            char p = buffer[i];
            buffer[i] = buffer[i + 1];
            buffer[i + 1] = p;
        }
        fwrite(buffer, 1, readed, fd);
    }
    rewind(fsf);
    // Add 5
    printf("Copying %s byte +5 to $%X\n", ag[2], (unsigned int) ftell(fd));
    while (readed = fread(&buffer, 1, 1024, fsf))  
    {
        for (int i = 0; i < readed; i++)
        {
            buffer[i] += 5;
        }
        fwrite(buffer, 1, readed, fd);
    }
    rewind(fsf);

    // xor 22
    printf("Copying %s XOR 22 to $%X\n", ag[2], (unsigned int) ftell(fd));
    while (readed = fread(&buffer, 1, 1024, fsf))  
    {
        for (int i = 0; i < readed; i++)
        {
            buffer[i] = buffer[i] ^ 22;
        }
        fwrite(buffer, 1, readed, fd);
    }
    unsigned int end_pos = ftell(fd);
    printf("Reached : $%lX, filling the rest with fsf data\n", ftell(fd));
    while (end_pos < 0x200000) {
        rewind(fsf);
        while ((readed = fread(&buffer, 1, 1024, fsf)) && end_pos < 0x200000)
        {
            fwrite(buffer, 1, readed, fd);
            end_pos = ftell(fd);
        }
        end_pos = ftell(fd);
    }
    fclose(fsf);
    unsigned int name_size = strlen(ag[1]);
    char* new_rom = (char*) malloc(strlen(ag[1]) + 6);
    strcpy(new_rom, ag[1]);
    strcpy(new_rom + name_size - 4, "_128k.sfc");
    printf("Creating a copied version with 128k sram\n");
    pid_t pid = fork();
    if (pid == 0)
        execlp("cp", "cp", ag[1], new_rom, NULL);
    else
    {
        int s;
        wait(&s);
    }
    FILE *new_fd = fopen(new_rom, "r+");
    fseek(new_fd, 0x7FD8, SEEK_SET);
    plop = 7;
    fwrite(&plop, 1, 1, new_fd);
    printf("Checking if the rom follows the expected data\n");
    if (validate_rom(fd) == false)
    {
        fprintf(stderr, "Error, the rom data does not match expected data\n");
        exit(1);
    }
    printf("ok\n");
    fclose(new_fd);
    fclose(fd);
}

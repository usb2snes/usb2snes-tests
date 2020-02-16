#include <string.h>
#include <stdio.h>


int main(int ac, char *ag[])
{
    if (ac != 3)
        return -1;
    FILE* fd = fopen(ag[1], "r+");
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
    fclose(fsf);
    fclose(fd);
}

/* 
 *
 *  MIT License
 *  
 *  Copyright (c) 2019 Mario Rubio
 *  
 *  Permission is hereby granted, free of charge, to any person obtaining a copy
 *  of this software and associated documentation files (the "Software"), to deal
 *  in the Software without restriction, including without limitation the rights
 *  to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
 *  copies of the Software, and to permit persons to whom the Software is
 *  furnished to do so, subject to the following conditions:
 *  
 *  The above copyright notice and this permission notice shall be included in all
 *  copies or substantial portions of the Software.
 *  
 *  THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
 *  IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
 *  FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
 *  AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
 *  LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
 *  OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
 *  SOFTWARE.
 * 
 */

#include "json2pcap.h"
#include "common.h"

#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <jansson.h>

// https://stackoverflow.com/questions/2736753/how-to-remove-extension-from-file-name
char *remove_ext(char *string)
{
    char *retstr;
    char *lastdot;
    if(string == NULL)
        return NULL;
    if((retstr = malloc(strlen(string) + 1)) == NULL)
        return NULL;

    strcpy(retstr, string);
    lastdot = strrchr(retstr, '.');
    if(lastdot != NULL)
        *lastdot = '\0';
    
    return retstr;
}

char *add_ext(char *string, char *ext, size_t ext_size)
{
    char *retstr;
    if(string == NULL)
        return NULL;
    if((retstr = malloc(strlen(string) + 1 + 1 + ext_size)) == NULL)
        return NULL;

    strcpy(retstr, string);
    strcat(retstr, ".");
    strcat(retstr, ext);
    strcat(retstr, "\0");

    return retstr;
}

int main(int argc, char const *argv[])
{
    if(argc != 2)
    {
        LOG("Usage: %s json_file\n", argv[0]);
        return -1;
    }

    char *json_file = (char *)argv[1];
    char *file_base = remove_ext(json_file);
    char *pcap_file = add_ext(file_base, "pcap", 4);
    // LOG("%s\n", json_file);
    // LOG("%s\n", file_base);
    // LOG("%s\n", pcap_file);
    size_t num_pcks;

    LOG("Loading JSON file...\n");
    /* ## JSON LOAD ## */
    j2p_err_t j2p_err;
    json_t *json = load_json(json_file, &j2p_err);
    
    if(j2p_err != J2P_OK)
    {
        if(j2p_err == J2P_ERR_INVALID_JSON_ROUTE)
            LOG("Invalid input file!\n");
        else
            LOG("Unknown error!\n");
            
        return -1;
    }

    /* ## PCAP INIT ## */
    pcap_hdr_t pcap_header;
    pcap_init(&pcap_header, 2, 4, 1025, 149);


    /* ## PCAP DUMP ## */
    LOG("Generating PCAP file...\n");
    if((j2p_err = json2pcap(&pcap_header, json, pcap_file, &num_pcks)) != J2P_OK)
        LOG("Invalid JSON file!\n");


    LOG("Got %lu data packages.\n", num_pcks);

    free(file_base);
    free(pcap_file);
    /* ## END ## */
    LOG("\nMario Rubio. 2019.\n");
    LOG("Bye!\n");
    return 0;
}
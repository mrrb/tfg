#include "json2pcap.h"
#include "common.h"

#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <jansson.h>
#include <inttypes.h>

json_t *load_json(char *json_file, j2p_err_t *json_err)
{
    // JSON load
    FILE *fp = fopen(json_file, "r");

    if(!fp && json_err != NULL)
    {
        *json_err = J2P_ERR_INVALID_JSON_ROUTE;
        return NULL;
    }
    fclose(fp);

    // fseek(fp, 0, SEEK_END);
    // long json_size = ftell(fp);
    // fseek(fp, 0, SEEK_SET);  /* same as rewind(fp); */

    // char *json_string = malloc(json_size + 1);
    // fread(json_string, 1, json_size, fp);
    // fclose(fp);
    // // LOG("%s", json_string);
    // json_string[json_size] = 0;

    // JSON parse
    json_error_t json_error;
    // json_t *json = json_loads(json_string, 0, &json_error);
    json_t *json = json_load_file(json_file, 0, &json_error);
    // free(json_string);

    if(!json)
    {
        LOG_E("%s\n", json_error.text);
        if(json_err != NULL)
            *json_err = J2P_ERR;
    }
    else if(json_err != NULL)
        *json_err = J2P_OK;

    return json;
}

j2p_err_t pcap_init(pcap_hdr_t *pcap_header, uint16_t v_major, uint16_t v_minor, uint32_t snaplen, uint32_t network)
{
    // 0xA1B2C3D4
    // 0xD4C3B2A1
    pcap_header->magic_number  = 0xA1B2C3D4;
    pcap_header->version_major = v_major;
    pcap_header->version_minor = v_minor;
    pcap_header->thiszone      = 0;
    pcap_header->sigfigs       = 0;
    pcap_header->snaplen       = snaplen;
    pcap_header->network       = network;

    return J2P_OK;
}

// void num2char(uint64_t num, char *out, size_t size)
// {
//     for(uint8_t i=0; i<size; ++i)
//     {
//         out[i] = (char)(num & (0xFF << i*8)) >> i*8;
//     }
// }


j2p_err_t json2pcap(pcap_hdr_t *pcap_header, json_t *json, char *file_name, size_t *num_pcks)
{
    FILE *fp = fopen(file_name, "w+");
    if(fp == NULL)
        return J2P_ERR;

    json_t *json_date = json_object_get(json, "date");
    json_t *json_data = json_object_get(json, "USB_data");
    if(!json_data && !json_date)
        return J2P_ERR_INVALID_JSON;

    long long int timestamp = json_integer_value(json_date);


    // for(int i =0; i<4; ++i)
    // {
    //     LOG_I("%x\n", (pcap_header->magic_number & (0xFF << i*8)) >> i*8);
    // }

    fwrite(&pcap_header->magic_number, 1, 4, fp);
    fwrite(&pcap_header->version_major, 1, 2, fp);
    fwrite(&pcap_header->version_minor, 1, 2, fp);
    fwrite(&pcap_header->thiszone, 1, 4, fp);
    fwrite(&pcap_header->sigfigs, 1, 4, fp);
    fwrite(&pcap_header->snaplen, 1, 4, fp);
    fwrite(&pcap_header->network, 1, 4, fp);

    size_t index;
    json_t *value;
    json_array_foreach(json_data, index, value)
    {
        pcaprec_hdr_t packet_header;

        json_t *packet_TxCMD = json_object_get(value, "TxCMD");
        json_t *packet_data_size = json_object_get(value, "DataLen");
        json_t *data = json_object_get(value, "data");
        if(!packet_data_size || !packet_TxCMD || !data)
            return J2P_ERR_INVALID_JSON;

        uint32_t len  = (uint32_t)json_integer_value(packet_data_size);
        uint8_t TxCMD = (uint8_t)json_integer_value(packet_TxCMD);
        
        packet_header.ts_sec   = timestamp;
        packet_header.ts_usec  = 0;
        packet_header.incl_len = len+1;
        packet_header.orig_len = len+1;

        fwrite(&packet_header.ts_sec, 1, 4, fp);
        fwrite(&packet_header.ts_usec, 1, 4, fp);
        fwrite(&packet_header.incl_len, 1, 4, fp);
        fwrite(&packet_header.orig_len, 1, 4, fp);

        fwrite(&TxCMD, 1, 1, fp);

        char *buf = (char*)calloc(sizeof(char), len);

        

        size_t index_data;
        json_t *value_data;
        json_array_foreach(data, index_data, value_data)
        {
            uint8_t iter_val  = (uint8_t)json_integer_value(value_data);
            buf[index_data] = (char)iter_val;
        }

        fwrite(buf, 1, len, fp);
        free(buf);
    }

    *num_pcks = index;

    fclose(fp);
    return J2P_OK;
}
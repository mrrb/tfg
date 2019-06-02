#ifndef _JSON2PCAP_H_
#define _JSON2PCAP_H_

#include <jansson.h>
#include <stdint.h>

typedef enum j2p_err_e
{
    J2P_OK,

    J2P_ERR,
    J2P_ERR_INVALID_JSON,
    J2P_ERR_INVALID_JSON_ROUTE,

    J2P_MAX,
} j2p_err_t;

// typedef enum pcap_endian_e
// {
//     PCAP_LITTLE_ENDIAN,
//     PCAP_BIG_ENDIAN,

//     PCAP_MAX,
// } pcap_endian_t;

typedef struct pcap_hdr_s {
        uint32_t magic_number;   /* magic number */
        uint16_t version_major;  /* major version number */
        uint16_t version_minor;  /* minor version number */
        int32_t  thiszone;       /* GMT to local correction */
        uint32_t sigfigs;        /* accuracy of timestamps */
        uint32_t snaplen;        /* max length of captured packets, in octets */
        uint32_t network;        /* data link type */
} pcap_hdr_t;

typedef struct pcaprec_hdr_s {
        uint32_t ts_sec;         /* timestamp seconds */
        uint32_t ts_usec;        /* timestamp microseconds */
        uint32_t incl_len;       /* number of octets of packet saved in file */
        uint32_t orig_len;       /* actual length of packet */
} pcaprec_hdr_t;



json_t *load_json(char *json_file, j2p_err_t *json_err);
j2p_err_t pcap_init(pcap_hdr_t *pcap_header, uint16_t v_major, uint16_t v_minor, uint32_t snaplen, uint32_t network);
j2p_err_t json2pcap(pcap_hdr_t *pcap_header, json_t *json, char *file_name, size_t *num_pcks);

#endif /* _JSON2PCAP_H_ */
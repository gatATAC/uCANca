/*
 * Copyright (C) Igor Sysoev
 * Copyright (C) 2007 Manlio Perillo (manlio.perillo@gmail.com)
 * Copyright (C) 2010 Phusion
 *
 * Redistribution and use in source and binary forms, with or without
 * modification, are permitted provided that the following conditions
 * are met:
 * 1. Redistributions of source code must retain the above copyright
 *    notice, this list of conditions and the following disclaimer.
 * 2. Redistributions in binary form must reproduce the above copyright
 *    notice, this list of conditions and the following disclaimer in the
 *    documentation and/or other materials provided with the distribution.
 *
 * THIS SOFTWARE IS PROVIDED BY AUTHOR AND CONTRIBUTORS ``AS IS'' AND
 * ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE
 * IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE
 * ARE DISCLAIMED.  IN NO EVENT SHALL AUTHOR OR CONTRIBUTORS BE LIABLE
 * FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL
 * DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS
 * OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION)
 * HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT
 * LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY
 * OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF
 * SUCH DAMAGE.
 */

#ifndef _PASSENGER_NGINX_CONFIGURATION_H_
#define _PASSENGER_NGINX_CONFIGURATION_H_

#include <ngx_config.h>
#include <ngx_http.h>

typedef struct {
    ngx_http_upstream_conf_t upstream_config;
    ngx_str_t    index;
    ngx_array_t *flushes;
    ngx_array_t *vars_len;
    ngx_array_t *vars;
    ngx_array_t *vars_source;
    
    ngx_flag_t   enabled;
    ngx_flag_t   use_global_queue;
    ngx_flag_t   friendly_error_pages;
    ngx_flag_t   union_station_support;
    ngx_flag_t   debugger;
    ngx_flag_t   show_version_in_header;
    ngx_str_t    environment;
    ngx_str_t    user;
    ngx_str_t    group;
    ngx_str_t    spawn_method;
    ngx_str_t    app_group_name;
    ngx_str_t    app_rights;
    ngx_int_t    min_instances;
    ngx_int_t    max_requests;
    ngx_int_t    framework_spawner_idle_time;
    ngx_int_t    app_spawner_idle_time;
    ngx_str_t    union_station_key;
    ngx_array_t *base_uris;
    ngx_array_t *union_station_filters;

#if (NGX_HTTP_CACHE)
    ngx_http_complex_value_t cache_key;
#endif

    /************************************/
} passenger_loc_conf_t;

typedef struct {
    ngx_str_t    root_dir;
    ngx_str_t    ruby;
    ngx_int_t    log_level;
    ngx_str_t    debug_log_file;
    ngx_flag_t   abort_on_startup_error;
    ngx_uint_t   max_pool_size;
    ngx_uint_t   max_instances_per_app;
    ngx_uint_t   pool_idle_time;
    ngx_flag_t   user_switching;
    ngx_str_t    default_user;
    ngx_str_t    default_group;
    ngx_str_t    analytics_log_dir;
    ngx_str_t    analytics_log_user;
    ngx_str_t    analytics_log_group;
    ngx_str_t    analytics_log_permissions;
    ngx_str_t    union_station_gateway_address;
    ngx_uint_t   union_station_gateway_port;
    ngx_str_t    union_station_gateway_cert;
    ngx_str_t    union_station_proxy_address;
    ngx_str_t    union_station_proxy_type;
    ngx_array_t *prestart_uris;
} passenger_main_conf_t;

extern const ngx_command_t   passenger_commands[];
extern passenger_main_conf_t passenger_main_conf;

void *passenger_create_main_conf(ngx_conf_t *cf);
char *passenger_init_main_conf(ngx_conf_t *cf, void *conf_pointer);
void *passenger_create_loc_conf(ngx_conf_t *cf);
char *passenger_merge_loc_conf(ngx_conf_t *cf, void *parent, void *child);

#endif /* _PASSENGER_NGINX_CONFIGURATION_H_ */


/* Copyright (c) 2019 noahc3
 * This Source Code Form is subject to the terms of the Mozilla Public
 * License, v. 2.0. If a copy of the MPL was not distributed with this
 * file, You can obtain one at http://mozilla.org/MPL/2.0/. */
using System;
using System.Collections.Generic;
using System.Linq;
using System.Threading.Tasks;
using Microsoft.AspNetCore.Builder;
using Microsoft.AspNetCore.Hosting;
using Microsoft.AspNetCore.Mvc;
using Microsoft.Extensions.Configuration;
using Microsoft.Extensions.DependencyInjection;
using Microsoft.AspNetCore;
using System.Net;
using Microsoft.Extensions.Logging;
using Microsoft.Extensions.Options;
using AspNetCoreRateLimit;

namespace SDSetupBackend {
    public class Startup {
        LoggerFactory loggerFactory = new LoggerFactory();

        public Startup(IConfiguration configuration) {
            Configuration = configuration;
        }

        public IConfiguration Configuration { get; }

        // This method gets called by the runtime. Use this method to add services to the container.
        public void ConfigureServices(IServiceCollection services) {

            services.AddOptions();
            services.AddMemoryCache();

            services.Configure<IpRateLimitOptions>(Configuration.GetSection("IpRateLimiting"));
            services.Configure<IpRateLimitPolicies>(Configuration.GetSection("IpRateLimitPolicies"));
            services.AddSingleton<IIpPolicyStore, MemoryCacheIpPolicyStore>();
            services.AddSingleton<IRateLimitCounterStore, MemoryCacheRateLimitCounterStore>();

            services.AddCors(options =>
            {
                options.AddPolicy("AllowAll",
                    builder => {
                        builder
                        .AllowAnyOrigin()
                        .AllowAnyMethod()
                        .AllowAnyHeader();
                    });
            });
            services.AddMvc().SetCompatibilityVersion(CompatibilityVersion.Version_2_1);
        }

        // This method gets called by the runtime. Use this method to configure the HTTP request pipeline.
        public void Configure(IApplicationBuilder app, IHostingEnvironment env) {
            loggerFactory.AddConsole(Configuration.GetSection("Logging"));
            loggerFactory.AddDebug();

            if (env.IsDevelopment()) {
                app.UseDeveloperExceptionPage();
            }

            app.UseForwardedHeaders(new ForwardedHeadersOptions {
                ForwardedHeaders = Microsoft.AspNetCore.HttpOverrides.ForwardedHeaders.XForwardedFor | Microsoft.AspNetCore.HttpOverrides.ForwardedHeaders.XForwardedProto
            });
            app.UseIpRateLimiting();

            // Add CORS headers to all responses, including errors and 404s
            app.Use(async (context, next) =>
            {
                try
                {
                    await next();
                }
                catch
                {
                    // Always add CORS headers on exception if response hasn't started
                    if (!context.Response.HasStarted && !context.Response.Headers.ContainsKey("Access-Control-Allow-Origin"))
                    {
                        context.Response.Headers.Add("Access-Control-Allow-Origin", "*");
                        context.Response.Headers.Add("Access-Control-Allow-Headers", "*");
                        context.Response.Headers.Add("Access-Control-Allow-Methods", "*");
                    }
                    throw;
                }
                
                // Add CORS headers to all responses if they haven't been added yet
                if (!context.Response.HasStarted && !context.Response.Headers.ContainsKey("Access-Control-Allow-Origin"))
                {
                    context.Response.Headers.Add("Access-Control-Allow-Origin", "*");
                    context.Response.Headers.Add("Access-Control-Allow-Headers", "*");
                    context.Response.Headers.Add("Access-Control-Allow-Methods", "*");
                }
            });

            app.UseCors("AllowAll");
            app.UseMvc();
        }
    }
}

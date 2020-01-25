## Deployment/production
OnlineJ uses puma as a rack server to host it in production you will need a web server like Apache or Nginx. We highly recommend Nginx, as it is a fast reverse proxy web server with support for multiple apps and extra cool feature. So below is a step-wise guide to host the app in production on a Ubuntu 16.06 LTS operating system with Puma and Nginx

1. Assuming your app is running all fine in development
2. Install Nginx `sudo apt-get install nginx`
3. Run `rake secret` and use this key in `config/secrets.yml` for production secret_key_base
4. Uncomment the line starting with `config.secret_key` in `config/initializers/devise.rb` and use the same key
5. Run `RAILS_ENV=production rake assets:precompile` to precompile assets for production

### Puma Configuration
1. Run `mkdir -p shared/pids shared/sockets shared/log`
2. Use `config/puma.prod.rb` for production, chnage according to your needs.

### Nginx Configuration
1. make the configuration for nginx in `/etc/nginx/nginx.conf` replace user with your user name

```
#user html;
worker_processes  1; # this may connect with the worker numbers puma can use.

#error_log  logs/error.log;
#error_log  logs/error.log  notice;
#error_log  logs/error.log  info;

#pid        logs/nginx.pid;


events {
    worker_connections  1024;
}

http {
	upstream app {
	    # Path to Puma SOCK file, as defined previously
 	    server unix:/home/user/OnlineJ/shared/sockets/puma.sock;
	}

	server {
	    listen 80;
	    server_name localhost; # or your server name

	    root /home/user/OnlineJ/public/assets/;

	    try_files $uri/index.html $uri @app;

	    location @app {
		proxy_pass http://app;
		proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
		proxy_set_header Host $http_host;
		proxy_redirect off;
	    }

	    error_page 500 502 503 504 /500.html;
	    client_max_body_size 4G;
	    keepalive_timeout 10;
	}
}
```
### Starting server
1. Start nginx with `sudo systemctl start nginx`
2. Start puma with `bundle exec puma -C config/puma.prod.rb -d` -d specifes to run as daemon
3. Start sidekiq with `bundle exec sidekiq -e production -d`
>To kill Puma server run killall bundle
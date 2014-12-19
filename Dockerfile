# PHP container v0.22

FROM wannabe/ubuntu

MAINTAINER Yury Borunov <yury@borunov.com>

# Install Nginx, PHP5-FPM.
RUN \
  	add-apt-repository -y ppa:nginx/stable && \	
	add-apt-repository -y ppa:ondrej/php5 && \
	apt-get update && \
	apt-get upgrade -y && \
	apt-get install -y php5-dev php5-mcrypt php5-fpm php5-curl php5-gd php5-mysql php5-memcache mysql-client-5.5 memcached nginx dialog supervisor && \
	rm -rf /var/lib/apt/lists/* 

RUN \
	sed -i -e "s/;cgi.fix_pathinfo=1/cgi.fix_pathinfo=0/g" /etc/php5/fpm/php.ini && \
	sed -i -e "s/upload_max_filesize\s*=\s*2M/upload_max_filesize = 100M/g" /etc/php5/fpm/php.ini && \
	sed -i -e "s/post_max_size\s*=\s*8M/post_max_size = 100M/g" /etc/php5/fpm/php.ini && \
	sed -i -e "s/;daemonize\s*=\s*yes/daemonize = no/g" /etc/php5/fpm/php-fpm.conf && \
	sed -i -e "s/expose_php\s*=\s*On/expose_php = Off/g" /etc/php5/fpm/php.ini && \
	sed -i -e "s/short_open_tag\s*=\s*Off/short_open_tag = On/g" /etc/php5/fpm/php.ini && \
	sed -i -e "s/short_open_tag\s*=\s*Off/short_open_tag = On/g" /etc/php5/cli/php.ini 

RUN \
	echo "fastcgi_param SCRIPT_FILENAME \$document_root\$fastcgi_script_name;" >> /etc/nginx/fastcgi_params && \
	echo "fastcgi_index index.php;" >> /etc/nginx/fastcgi_params && \
	echo "fastcgi_split_path_info ^(.+\.php)(.*)$;" >> /etc/nginx/fastcgi_params && \
	echo "fastcgi_param PATH_INFO \$fastcgi_path_info;" >> /etc/nginx/fastcgi_params && \
	echo "fastcgi_param HOSTNAME \$host;" >> /etc/nginx/fastcgi_params

ADD supervisord.conf /etc/supervisor/conf.d/
ADD supervisord_nginx.conf /etc/supervisor/conf.d/
ADD supervisord_php5fpm.conf /etc/supervisor/conf.d/

ADD nginx.conf /etc/nginx/nginx.conf

RUN mkdir /app

VOLUME /app

EXPOSE 80 443

WORKDIR /app

# CMD ["/usr/bin/supervisord"]
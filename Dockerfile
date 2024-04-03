# syntax=docker/dockerfile:1
FROM python:3.12-bookworm

ADD --chmod=755 https://astral.sh/uv/install.sh /install.sh
RUN /install.sh && rm /install.sh
RUN /root/.cargo/bin/uv pip install --system --no-cache supervisor

COPY crontab.txt /var/crontab.txt
RUN crontab /var/crontab.txt
RUN chmod 600 /etc/crontab

WORKDIR /user_pinger

COPY requirements.txt /user_pinger/requirements.txt
RUN /root/.cargo/bin/uv pip install --system --no-cache -r /user_pinger/requirements.txt

COPY --link supervisord.conf *.py /user_pinger/
COPY --link sql/ /user_pinger/sql/
COPY --link templates/ /user_pinger/templates/
COPY --link www/ /user_pinger/www/

CMD [ "supervisord", "-c", "/user_pinger/supervisord.conf" ]

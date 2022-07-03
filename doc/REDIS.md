<img src="../img/Redis-Logo.png" width="200px">


## TOC:
- 1. What is Redis?
- 2. Usefull commands
- 3. Configuration
- 4. Redis and Netbox
- 5. Check your redis for netbox

## 1. What is Redis?

Redis is a **in-memory** database for 'key - value pairs'

**Goal:** is to cache, frequently asked or needed, values 'in-memory' aiming for 'millisecond response times'. And thus on average 100x faster than multiple 100ms response times from API or database look-ups.

**Remark:** Every 'key' gets a configurable TTL(Time To Live). Example: when the TTL of a certain key is set to 60sec, the value will be available 60seconds after his last call. After 60s it will be removed.

## 2. Usefull commands

- 'monitor'
- 'AUTH' -> check password
- 'CONFIG SET requirepass -> set/no password

Redis has default no password as a backend and non-internet facing service.

When using a docker instance we can access the Redis host with
```
# docker exec -it HOSTNAME SHELL
docker exec -it netbox-cache sh
```

Then we start the redis-cli:
```
# enter the redis cli
$ redis-cli
127.0.0.1:6379>

# monitor API calls to redis
127.0.0.1:6379>monitor
```

```
# check password
127.0.0.1:6379> AUTH
ok

# set password 
127.0.0.1:6379> CONFIG SET requirepass "redis123"

# check
127.0.0.1:6379> AUTH redis123
ok
# set no password
127.0.0.1:6379> CONFIG SET requirepass ""
```

## 3. Configuration

Default there is NO **redis.conf** file. Default settings will be applied, including 'requirepass no'.

Custom settings can be applied via a 'redis.conf' file that is givven as a argument to **redis-server /path/to/redis.conf** when the server is started.

See example: redis.conf (2281 lines :-)

- line 1041 -> uncomment to set password-> 'requirepass redis123'

## 4. Redis and netbox on RPI

**Step 1:** map your  host(RPI) directory **that contains your 'redis.conf' file** to a volume in the container

See second entry unde **volumes**:
- /path_on_host:/path_in_container

ps: ${SERVICE_DATA_DIR} is an environment variable we have configured in .env and is picked up by docker-compose. If you do not succeed, first start hardcoding your path

**Step 2:** We will provide the '/path_in_container/redis.conf' as argument to the **redis-server** when it starts.

This 'argument' is provided via the 'command' option in the docker-compose.yml file. 

ps: The 'ENTRYPOINT' from the redis container will start the server 'redis-server' and the 'command' will append the path, resulting in:

**'redis-server /path_in_container/redis.conf'**

### Important part of the docker-compose file for redis
```
#... see this part of redis config in docker-compose.yml
    command:
      - /usr/local/etc/redis/redis.conf
    volumes:
      - ${SERVICE_DATA_DIR}/netbox-cache/data:/data
      - ${SERVICE_DATA_DIR}/netbox-cache/conf:/usr/local/etc/redis

```

## 5. Check your Redis for Netbox

1) Make sure you have 'uncomment' line 1041. And give it the same password as you entered in the netbox container configuration file 'netbox.env' (eg: 'REDIS_PASSWORD=redis123')

```
# approx line 1041 in redis.conf
requirepass redis123
```

2) Check your redis server and that 'redis.conf' was loaded correctly.
   
```
# enter into running redis container 'netbox-cache'
docker exec -it netbox-cache sh

#start redis cli
$redis-cli

127.0.0.1:6379> AUTH redis123
ok
```

If you end up here, you are a devops star!
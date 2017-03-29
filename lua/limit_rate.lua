local conf = require "config"

---------  start  --------
local limit_req = require "resty.limit.req"

-- 限制请求速率为200 req/sec，并且允许100 req/sec的突发请求
local lim, err = limit_req.new("limit_req_store", 2, 1)

if not lim then 
	ngx.log(ngx.ERR, "failed to instantiate a resty.limit.req object: ", err)
	return ngx.exit(500)
end

-- 下面代码针对每一个单独的请求
-- 使用ip地址作为限流的key
local key = ngx.var.binary_remote_addr
local delay, err = lim:incoming(key, true)
if not delay then 
	if err == "rejected" then 
		return ngx.exit(503)
	end
		
	ngx.log(ngx.ERR, "failed to limit req: ", err)
	return ngx.exit(500)
end	

if delay > 0 then 
	-- 第二个参数(err)保存着超过请求速率的请求数
    -- 例如err等于31，意味着当前速率是231 req/sec
	local excess = err
	
	ngx.sleep(delay)
end	
	
	
import subprocess, datetime, telnetlib, os, time
from os.path import dirname, realpath

shard_dict = {'27001': 'shard1', '27002': 'shard2', '27003': 'shard3', '27010': 'mongos', '27011': 'cfgsvr'}


def is_port_open(ip, port):
    is_open = False
    try:
        tn = telnetlib.Telnet(ip, port, timeout=2)
        is_open = True
        tn.close()
    except:
        pass

    return is_open


def write_log(log: str):
    if log:
        file = open("/var/check_mongo_service.log", "a")
        now = datetime.datetime.now().strftime('%Y-%m-%d %H:%M:%S')
        file.write('{} {}\n'.format(now, log))
        file.close()


def kill_mongod(pid):
    cmd = 'kill -9 {}'.format(pid)
    write_log(cmd)
    os.system(cmd)


def start_mongo_process(sh_name: str):
    work_dir = dirname(realpath(__file__))
    p = subprocess.Popen(["bash", work_dir + '/' + sh_name], stdout=subprocess.PIPE, stderr=subprocess.STDOUT)
    for line in p.stdout.readlines():
        info = line.decode('utf-8')
        write_log(info)


def check_mongo_port_service():
    # 检查端口是否能够提供服务
    for port, shard_name in shard_dict.items():
        is_open = is_port_open('127.0.0.1', port)
        if not is_open:
            sh_name = shard_name + '_start.sh'
            start_mongo_process(sh_name)


def check_shard_memory():
    import psutil
    for p in psutil.process_iter():

        if 'shard1' in p.cmdline() and int(p.memory_percent()) > 35:
            kill_mongod(p.pid)
            time.sleep(2)

            sh_name = 'shard1_start.sh'
            start_mongo_process(sh_name)

        if 'shard2' in p.cmdline() and int(p.memory_percent()) > 35:
            kill_mongod(p.pid)
            time.sleep(2)

            sh_name = 'shard2_start.sh'
            start_mongo_process(sh_name)

        if 'shard3' in p.cmdline() and int(p.memory_percent()) > 35:
            kill_mongod(p.pid)
            time.sleep(2)

            sh_name = 'shard3_start.sh'
            start_mongo_process(sh_name)


def main():
    check_mongo_port_service()
    #check_shard_memory()


main()


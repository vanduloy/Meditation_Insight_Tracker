# import paho.mqtt.client as mqtt
# import ssl
# import json
# from datetime import datetime
# import time

# # AWS IoT 配置
# aws_iot_endpoint = "a2bgd40amyhrlj-ats.iot.us-east-1.amazonaws.com"  # 替换为您的 AWS IoT 端点
# cert_file = "Certificates/certificate.pem.crt"
# key_file = "Certificates/private.pem.key"
# ca_file = "Certificates/AmazonRootCA1.pem"
# topic = "ecg/data/test"

# # 简单的测试数据
# test_data = {
#     "ecgRecord": {
#         "userId": "user123",
#         "startTime": datetime.now().isoformat(),
#         "endTime": (datetime.now() + timedelta(minutes=1)).isoformat(),
#         "samples": [
#             {"time": i, "voltage": round(random.uniform(-1.0, 1.0), 2)}
#             for i in range(60)  # 生成60个样本，模拟1分钟的数据
#         ]
#     }
# }

# # 回调函数
# def on_connect(client, userdata, flags, rc):
#     print(f"Connected with result code {rc}")
#     if rc == 0:
#         print("Sending test data...")
#         client.publish(topic, json.dumps(test_data), qos=1)
#     else:
#         print("Failed to connect")

# def on_publish(client, userdata, mid):
#     print(f"Message {mid} published")
#     client.disconnect()  # 发送完消息后断开连接

# # 创建 MQTT 客户端
# client = mqtt.Client()
# client.on_connect = on_connect
# client.on_publish = on_publish

# # 设置 TLS/SSL
# client.tls_set(ca_file,
#                certfile=cert_file,
#                keyfile=key_file,
#                cert_reqs=ssl.CERT_REQUIRED,
#                tls_version=ssl.PROTOCOL_TLSv1_2,
#                ciphers=None)

# # 连接到 AWS IoT
# print("Connecting to AWS IoT...")
# client.connect(aws_iot_endpoint, 8883, 60)

# # 开始循环
# client.loop_forever()

##################################################################################

# import paho.mqtt.client as mqtt
# import ssl
# import json
# import time
# from flask import Flask, request, jsonify

# # AWS IoT 配置
# aws_iot_endpoint = "a2bgd40amyhrlj-ats.iot.us-east-1.amazonaws.com"
# cert_file = "Certificates/certificate.pem.crt"
# key_file = "Certificates/private.pem.key"
# ca_file = "Certificates/AmazonRootCA1.pem"
# topic = "ecg/data/test"

# app = Flask(__name__)

# # MQTT客户端设置
# client = mqtt.Client()
# client.tls_set(ca_file,
#                certfile=cert_file,
#                keyfile=key_file,
#                cert_reqs=ssl.CERT_REQUIRED,
#                tls_version=ssl.PROTOCOL_TLSv1_2,
#                ciphers=None)

# def on_connect(client, userdata, flags, rc):
#     print(f"Connected with result code {rc}")

# def on_publish(client, userdata, mid):
#     print(f"Message {mid} published")

# client.on_connect = on_connect
# client.on_publish = on_publish

# # 连接到AWS IoT
# print("Connecting to AWS IoT...")
# client.connect(aws_iot_endpoint, 8883, 60)
# client.loop_start()

# @app.route('/upload', methods=['POST'])
# def upload_data():
#     try:
#         ecg_data = request.json
#         print(f"Received ECG data: {ecg_data}")
        
#         # 发布到AWS IoT
#         result = client.publish(topic, json.dumps(ecg_data), qos=1)
#         if result.rc == mqtt.MQTT_ERR_SUCCESS:
#             print("ECG data published to AWS IoT")
#             return jsonify({"status": "success", "message": "Data uploaded and published"}), 200
#         else:
#             print(f"Failed to publish ECG data: {result.rc}")
#             return jsonify({"status": "error", "message": "Failed to publish data"}), 500
#     except Exception as e:
#         print(f"Error processing request: {e}")
#         return jsonify({"status": "error", "message": str(e)}), 500

# if __name__ == '__main__':
#     app.run(host='0.0.0.0', port=8888)

##################################################################################

from flask import Flask, request, jsonify
import paho.mqtt.client as mqtt
import ssl
import json
import time
import queue
import threading

# 配置
aws_iot_endpoint = "a2bgd40amyhrlj-ats.iot.us-east-1.amazonaws.com"
thing_name = "ECGDevice"
root_ca_path = "Certificates/AmazonRootCA1.pem"
certificate_path = "Certificates/certificate.pem.crt"
private_key_path = "Certificates/private.pem.key"
topic = "ecg/data"
CHUNK_SIZE = 128 * 1024 - 1000  # 小于128KB

app = Flask(__name__)
message_queue = queue.Queue()

class MQTTClient:
    def __init__(self):
        self.client = mqtt.Client(client_id=thing_name, protocol=mqtt.MQTTv5)
        self.client.tls_set(root_ca_path,
                            certfile=certificate_path,
                            keyfile=private_key_path,
                            cert_reqs=ssl.CERT_REQUIRED,
                            tls_version=ssl.PROTOCOL_TLSv1_2,
                            ciphers=None)
        self.client.on_connect = self.on_connect
        self.client.on_disconnect = self.on_disconnect
        self.connect()

    def connect(self):
        try:
            self.client.connect(aws_iot_endpoint, port=8883, keepalive=60)
            self.client.loop_start()
        except Exception as e:
            print(f"Failed to connect: {e}")

    def on_connect(self, client, userdata, flags, rc, properties=None):
        if rc == 0:
            print("Successfully connected to AWS IoT")
        else:
            print(f"Failed to connect, return code {rc}")

    def on_disconnect(self, client, userdata, rc, properties=None):
        print(f"Disconnected with result code: {rc}")
        print("Attempting to reconnect...")
        self.connect()

    def publish(self, topic, message):
        return self.client.publish(topic, message)

mqtt_client = MQTTClient()

def chunk_data(data):
    chunks = []
    for i in range(0, len(data), CHUNK_SIZE):
        chunks.append(data[i:i + CHUNK_SIZE])
    return chunks

def message_sender():
    while True:
        try:
            topic, message = message_queue.get(block=True)
            print(f"Preparing to send message to topic: {topic}")
            chunks = chunk_data(message)
            for index, chunk in enumerate(chunks):
                print(f"Sending chunk {index + 1}/{len(chunks)} to {topic}/{index}")
                result = mqtt_client.publish(f"{topic}/{index}", chunk)
                if result.rc == mqtt.MQTT_ERR_SUCCESS:
                    print(f"Successfully published chunk {index + 1}")
                else:
                    print(f"Failed to publish chunk {index + 1}: {result.rc}")
                time.sleep(0.1)
            message_queue.task_done()
            print(f"Finished sending message to {topic}")
        except Exception as e:
            print(f"Error in message sender: {e}")

# 启动消息发送线程
sender_thread = threading.Thread(target=message_sender, daemon=True)
sender_thread.start()

@app.route('/upload', methods=['POST'])
def upload_data():
    try:
        data = request.json
        if "ecgRecord" in data:
            ecg_record = data["ecgRecord"]
            parsed_data =  {
                "userId": ecg_record["userId"],
                "startTime": ecg_record["startTime"],
                "endTime": ecg_record["endTime"],
                "samples": [
                    {
                        "time": sample["time"],
                        "voltage": sample["voltage"]
                    } for sample in ecg_record["samples"]
                ]
            }
            
            message = json.dumps({"data": parsed_data, "timestamp": time.time()})
            message_queue.put((topic, message))
            
            return jsonify({"status": "success", "message": "Data queued for upload"}), 200
        else:
            raise ValueError("Invalid data format: 'ecgRecord' key not found")
    except Exception as e:
        print(f"Error processing request: {e}")
        return jsonify({"status": "error", "message": str(e)}), 500

if __name__ == '__main__':
    app.run(host='0.0.0.0', port=8888)



/* 2023年11月07日16:06:34 MadDog-Wen */
const chat = $('#chat');    //消息日志
const messageInput = $('#message'); //发送消息框
const sendButton = $('#send');  //发送按钮

let pingTimer; // 定时器用于发送 Ping 消息
let pongReceived = true; // 标记是否收到 Pong 响应

$(document).ready(function() {
    // 当连接建立时触发

    // 连接成功时的回调函数
    client.on('connect', function () {
        console.log('连接成功');
        $('#webState').html('服务端：<span class="badge text-bg-success">在线</span>');

        /*
        // 订阅一个主题
        client.subscribe('your/topic', function (err) {
        if (!err) {
            console.log('订阅成功');
        }
        });
        */
    });

    // 收到消息时的回调函数
    client.on('message', function (topic, message) {
        // message is Buffer
        console.log('收到消息:', message.toString());
        const receivedMessage = message.toString();
        displayMessage(receivedMessage);
        // 收到响应
        pongReceived = true;
    });

    // 连接断开时的回调函数
    client.on('close', function () {
        console.log('连接已断开');
        closeWeb('服务端：<span class="badge text-bg-secondary">离线</span>');
    });

    // 发生错误时的回调函数
    client.on('error', function (error) {
        console.error('发生错误:', error);
        closeWeb('服务端：<span class="badge text-bg-info">连接中断</span>');
    });

    // 发送消息
    sendButton.click(function() {
        // 发布一条消息
        client.publish('your/topic', messageInput.val());
        displayMessage(`服务端: ${messageInput.val()}`);
    });

    /*** 
     * 
     * 以下为通用监听
     * 
    */
    // 使用事件委托来监听所有复选框的状态变化

    // 监听所有 A 标签的点击事件
    $(document).on('click', 'a', function() {
        //获取按下的ID
        var aboxId = $(this).attr('id');
        //发送按下的消息
        client.publish(topic, aboxId);
    });
    /*** 
     * 
     * 通用监听结束
     * 
    */
});

// 用户重新回到页面，刷新当前页面
$(document).on('visibilitychange', function() {
    if (document.visibilityState === 'visible') {
        location.reload();
    }
});

// 处理接收到的消息
function displayMessage(message) {
    $('#iotState').html('设备端：<span class="badge text-bg-primary">在线</span>');
    // 在聊天框中显示消息
    chat.append(message + "\n");
}

//处理断开事件
function closeWeb(msg){
    //设置服务端状态
    $('#webState').html(msg);
    // 清除 Ping 定时器
    clearInterval(pingTimer);
}
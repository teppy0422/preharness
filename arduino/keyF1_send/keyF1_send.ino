#include "Keyboard.h"

// ボタン接続ピン
const int buttonPin = 5; // デジタルピン2にボタンを接続
const int ledPin = 4;    // デジタルピン4をLED出力に使用

// チャタリング対策用変数
const unsigned long debounceDelay = 50; // デバウンス時間（ミリ秒）
int lastButtonState = HIGH;
int buttonState;
unsigned long lastDebounceTime = 0;
bool keyAlreadySent = false; // キー送信済みフラグ

void setup() {
  // キーボード機能を初期化
  Keyboard.begin();
  
  // シリアル通信を開始（デバッグ用）
  Serial.begin(9600);
  
  // 内蔵LEDピンを出力に設定
  pinMode(LED_BUILTIN, OUTPUT);
  digitalWrite(ledPin, LOW); // 初期状態：消灯

  
  // ボタンピンを入力プルアップに設定
  pinMode(buttonPin, INPUT_PULLUP);
  
  Serial.println("Arduino Leonardo F1 Key with Button Ready (Pin 2)");
}

// シリアル入力のチャタリング対策用変数
unsigned long lastSerialTime = 0;
const unsigned long serialDebounceDelay = 500; // シリアル入力の重複防止時間

void loop() {
  // ボタンの現在の状態を読み取り
  int reading = digitalRead(buttonPin);
  
  // ボタンの状態が前回と異なる場合（ノイズまたは実際の押下）
  if (reading != lastButtonState) {
    // デバウンスタイマーをリセット
    lastDebounceTime = millis();
  }
  
  // デバウンス時間が経過した場合
  if ((millis() - lastDebounceTime) > debounceDelay) {
    // ボタンの状態が実際に変化した場合
    if (reading != buttonState) {
      buttonState = reading;
      
      // ボタンが押された場合（HIGH → LOW）かつまだキーを送信していない場合
      if (buttonState == LOW && !keyAlreadySent) {
        sendF1Key();
        keyAlreadySent = true; // フラグを設定して重複送信を防ぐ
      }
      
      // ボタンが離された場合（LOW → HIGH）
      if (buttonState == HIGH) {
        keyAlreadySent = false; // フラグをリセット
      }
    }
  }
  
  // 前回の状態を更新
  lastButtonState = reading;
  
  // 1秒間隔でF1キーを自動送信する場合は以下をコメントアウト
  /*
  sendF1Key();
  delay(1000);
  */
}

void sendF1Key() {
  // LEDを点灯してキー送信を示す
  digitalWrite(LED_BUILTIN, HIGH);

    // 4番ピンのLEDを点灯
  digitalWrite(ledPin, HIGH);
  
  Keyboard.print("abc");
  // F1キーを押す
  Keyboard.press(KEY_F1);
  delay(50); // 短い遅延
  // F1キーを離す
  Keyboard.release(KEY_F1);

  
  // LEDを消灯
  digitalWrite(LED_BUILTIN, LOW);
  // digitalWrite(ledPin, LOW);

  Serial.println("F1 key sent by button press!");
}

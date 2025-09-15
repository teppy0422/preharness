class WorkflowState {
  bool crimpConditionComplete = false;
  bool measurementComplete = false;
  bool productionStarted = false;
  
  // 進捗段階の計算
  int get currentStep {
    if (!crimpConditionComplete) return 1; // 部材照合段階
    if (!measurementComplete) return 2;    // 測定段階
    if (!productionStarted) return 3;      // 生産開始準備段階
    return 4;                              // 生産中
  }
  
  // 次のステップに進めるか
  bool get canMoveToMeasurement => crimpConditionComplete;
  bool get canStartProduction => crimpConditionComplete && measurementComplete;
  
  // 進捗率計算
  double get progressPercent {
    if (productionStarted) return 1.0;
    if (measurementComplete) return 0.75;
    if (crimpConditionComplete) return 0.5;
    return 0.25;
  }
  
  // ステップ名
  String get currentStepName {
    switch (currentStep) {
      case 1: return '部材照合';
      case 2: return '測定確認';
      case 3: return '生産準備完了';
      case 4: return '生産中';
      default: return '準備中';
    }
  }
  
  void reset() {
    crimpConditionComplete = false;
    measurementComplete = false;
    productionStarted = false;
  }
}
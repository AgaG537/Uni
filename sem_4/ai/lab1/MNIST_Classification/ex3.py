import keras
import numpy as np
import matplotlib.pyplot as plt
import seaborn as sns
import pandas as pd
from sklearn.ensemble import RandomForestClassifier
from sklearn.metrics import accuracy_score, classification_report, confusion_matrix

(x_train, y_train), (x_test, y_test) = keras.datasets.mnist.load_data()

x_train = x_train.reshape(len(x_train), -1)
x_test = x_test.reshape(len(x_test), -1)
x_train = x_train / 255.0
x_test = x_test / 255.0

clf = RandomForestClassifier(n_estimators=100, random_state=42, n_jobs=-1)
clf.fit(x_train, y_train)

y_pred = clf.predict(x_test)

accuracy = accuracy_score(y_test, y_pred)
print(f'Accuracy on test set: {accuracy:.4f}')


# Generating classification report (precision, recall, f1 score)
report_custom = classification_report(y_test, y_pred, digits=2, output_dict=True, zero_division=0)
report_custom_df = pd.DataFrame(report_custom).transpose().round(2)

selected_classes = [str(i) for i in range(10)]  # Classes 0-9
report_filtered = report_custom_df.loc[selected_classes, ["precision", "recall", "f1-score"]]

plt.figure(figsize=(9, 6))
sns.heatmap(report_filtered, annot=True, cmap="Blues", fmt=".2f", linewidths=0.5)

plt.title(f"Classification Report - MNIST Digits\nAccuracy: {accuracy:.2f}", fontsize=14, pad=15)
plt.xlabel("Metrics", fontsize=11)
plt.ylabel("Classes", fontsize=11)
plt.xticks(fontsize=10)
plt.yticks(fontsize=10, rotation=0)
plt.savefig("3_classification_report.png", bbox_inches='tight')
plt.show()


# Confusion Matrix
cm = confusion_matrix(y_test, y_pred)
plt.figure(figsize=(10, 7))
sns.heatmap(cm, annot=True, fmt='d', cmap='Blues', xticklabels=np.arange(10), yticklabels=np.arange(10))
plt.title('Confusion Matrix - MNIST Digits')
plt.xlabel('Predicted')
plt.ylabel('True')
plt.savefig("3_confusion_matrix.png", bbox_inches='tight')
plt.show()

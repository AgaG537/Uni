import keras
import numpy as np
import matplotlib.pyplot as plt
import seaborn as sns
import pandas as pd
from sklearn.ensemble import RandomForestClassifier
from sklearn.metrics import accuracy_score, classification_report, confusion_matrix
import os
from PIL import Image

(x_train, y_train), (x_test, y_test) = keras.datasets.mnist.load_data()

folder_path = "my_nums/"
file_names = sorted(os.listdir(folder_path))

images = []
labels = []

for file in file_names:
    img = Image.open(os.path.join(folder_path, file)).convert("L")
    img = np.array(img) / 255.0
    img = img.reshape(28, 28, 1)
    label = int(file[0])

    images.append(img)
    labels.append(label)

x_custom_test = np.array(images)
y_custom_test = np.array(labels)

x_train = x_train.reshape(len(x_train), -1)
x_custom_test = x_custom_test.reshape(len(x_custom_test), -1)
x_train = x_train / 255.0

clf = RandomForestClassifier(n_estimators=100, random_state=42, n_jobs=-1)
clf.fit(x_train, y_train)

y_pred = clf.predict(x_custom_test)

accuracy = accuracy_score(y_custom_test, y_pred)
print(f'Accuracy on test set: {accuracy:.4f}')


# Generating classification report (precision, recall, f1 score)
report_custom = classification_report(y_custom_test, y_pred, digits=2, output_dict=True, zero_division=0)
report_custom_df = pd.DataFrame(report_custom).transpose().round(2)

selected_classes = [str(i) for i in range(10)]  # Klasy 0-9
report_filtered = report_custom_df.loc[selected_classes, ["precision", "recall", "f1-score"]]

plt.figure(figsize=(9, 6))
sns.heatmap(report_filtered, annot=True, cmap="Blues", fmt=".2f", linewidths=0.5)

plt.title(f"Classification Report - Custom Digits\nAccuracy: {accuracy:.2f}", fontsize=14, pad=15)
plt.xlabel("Metrics", fontsize=11)
plt.ylabel("Classes", fontsize=11)
plt.xticks(fontsize=10)
plt.yticks(fontsize=10, rotation=0)
plt.savefig("3_1_classification_report.png", bbox_inches='tight')
plt.show()


# Confusion Matrix
cm = confusion_matrix(y_custom_test, y_pred)
plt.figure(figsize=(10, 7))
sns.heatmap(cm, annot=True, fmt='d', cmap='Blues', xticklabels=np.arange(10), yticklabels=np.arange(10))
plt.title(f"Confusion Matrix - Custom Digits", fontsize=14, pad=15)
plt.xlabel('Predicted')
plt.ylabel('True')
plt.savefig("3_1_confusion_matrix.png", bbox_inches='tight')
plt.show()

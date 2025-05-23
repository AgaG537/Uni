import keras
import os
import numpy as np
import matplotlib.pyplot as plt
import seaborn as sns
import pandas as pd
from PIL import Image
from sklearn.metrics import confusion_matrix, classification_report

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


model = keras.models.load_model("neural_network_model.keras")
y_custom_pred = np.argmax(model.predict(x_custom_test), axis=1)

for i in range(len(y_custom_test)):
    print(f"Expected: {y_custom_test[i]}, Predicted: {y_custom_pred[i]}")

accuracy_custom = np.mean(y_custom_pred == y_custom_test)
print(f"Custom dataset accuracy: {accuracy_custom:.4f}")


# Generating classification report (precision, recall, f1 score)
report_custom = classification_report(y_custom_test, y_custom_pred, digits=2, output_dict=True, zero_division=0)
report_custom_df = pd.DataFrame(report_custom).transpose().round(2)

selected_classes = [str(i) for i in range(10)]  # Classes 0-9
report_filtered = report_custom_df.loc[selected_classes, ["precision", "recall", "f1-score"]]

plt.figure(figsize=(9, 6))
sns.heatmap(report_filtered, annot=True, cmap="Blues", fmt=".2f", linewidths=0.5)

plt.title(f"Classification Report - Custom Digits\nAccuracy: {accuracy_custom:.2f}", fontsize=14, pad=15)
plt.xlabel("Metrics", fontsize=11)
plt.ylabel("Classes", fontsize=11)
plt.xticks(fontsize=10)
plt.yticks(fontsize=10, rotation=0)
plt.savefig("2_classification_report.png", bbox_inches='tight')
plt.show()


# Confusion Matrix
cm_custom = confusion_matrix(y_custom_test, y_custom_pred)
plt.figure(figsize=(8, 6))
sns.heatmap(cm_custom, annot=True, fmt="d", cmap="Blues",
            xticklabels=[str(i) for i in range(10)],
            yticklabels=[str(i) for i in range(10)])
plt.xlabel("Predicted")
plt.ylabel("Actual")
plt.title("Confusion Matrix - Custom Digits")
plt.savefig("2_confusion_matrix.png", bbox_inches='tight')
plt.show()
import keras
import numpy as np
import matplotlib.pyplot as plt
import seaborn as sns
from sklearn.metrics import classification_report, confusion_matrix, accuracy_score
import pandas as pd

keras.utils.set_random_seed(123)
np.random.seed(123)
dataset = keras.datasets.mnist
(x_train, y_train), (x_test, y_test) = dataset.load_data()
x_train, x_test = x_train / 255.0, x_test / 255.0


model = keras.Sequential([
    keras.layers.Input(shape=(28, 28, 1)),
    keras.layers.Conv2D(32, kernel_size=(3, 3), activation="relu"),
    keras.layers.MaxPooling2D(pool_size=(2, 2)),
    keras.layers.Conv2D(128, kernel_size=(3, 3), activation="relu"),
    keras.layers.MaxPooling2D(pool_size=(2, 2)),
    keras.layers.Flatten(),
    keras.layers.Dense(128, activation='relu'),
    keras.layers.Dense(10, activation='softmax')
])

model.compile(optimizer='adam',
              loss='sparse_categorical_crossentropy',
              metrics=['accuracy'])

data = model.fit(x_train, y_train, epochs=10, validation_data=(x_test, y_test))

test_loss, test_acc = model.evaluate(x_test, y_test, verbose=2)
print(f'Accuracy on test set: {test_acc:.4f}')

y_pred = np.argmax(model.predict(x_test), axis=1)


# Accuracy and Loss Plots
plt.figure(figsize=(12, 5))
plt.subplot(1, 2, 1)
plt.plot(data.history['accuracy'], label='Train Accuracy')
plt.plot(data.history['val_accuracy'], label='Test Accuracy')
plt.xlabel('Epochs')
plt.ylabel('Accuracy')
plt.legend()
plt.title('Model Accuracy')

plt.subplot(1, 2, 2)
plt.plot(data.history['loss'], label='Train Loss')
plt.plot(data.history['val_loss'], label='Test Loss')
plt.xlabel('Epochs')
plt.ylabel('Loss')
plt.legend()
plt.title('Model Loss')
plt.savefig("1_acc_loss.png", bbox_inches='tight')
plt.show()



# Generating classification report (precision, recall, f1 score)
report_custom = classification_report(y_test, y_pred, digits=2, output_dict=True, zero_division=0)
report_custom_df = pd.DataFrame(report_custom).transpose().round(2)

selected_classes = [str(i) for i in range(10)]  # Klasy 0-9
report_filtered = report_custom_df.loc[selected_classes, ["precision", "recall", "f1-score"]]

plt.figure(figsize=(9, 6))
sns.heatmap(report_filtered, annot=True, cmap="Blues", fmt=".2f", linewidths=0.5)

plt.title(f"Classification Report", fontsize=14, pad=15)
plt.xlabel("Metrics", fontsize=11)
plt.ylabel("Classes", fontsize=11)
plt.xticks(fontsize=10)
plt.yticks(fontsize=10, rotation=0)
plt.savefig("1_classification_report.png", bbox_inches='tight')
plt.show()


# Confusion Matrix
cm = confusion_matrix(y_test, y_pred)
plt.figure(figsize=(10, 8))
sns.heatmap(cm, annot=True, fmt='d', cmap='Blues',
            xticklabels=[str(i) for i in range(10)],
            yticklabels=[str(i) for i in range(10)])
plt.xlabel('Predicted')
plt.ylabel('Actual')
plt.title('Confusion Matrix')
plt.savefig("1_confusion_matrix.png", bbox_inches='tight')
plt.show()


# Saving model
model.save("neural_network_model.keras")
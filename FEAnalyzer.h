#pragma once

#include <vector>
#include <QObject>
#include <QVariantList>
#include <Eigen/Dense>
#include "Vec2f.h"
struct Output;
struct Input;

class FEAnalyzer : public QObject {
  Q_OBJECT
  Q_PROPERTY(float relaxation READ relaxation WRITE setRelaxation NOTIFY relaxationChanged)
public:
    explicit FEAnalyzer();
    virtual ~FEAnalyzer();

    void setRelaxation(float r);
    float relaxation() const;

public slots:
  void processBridge(const QVariantList& nodes,
                     const QVariantList& beams);
  void step();

signals:
  void relaxationChanged();
  void processingComplete(const QVariantList& nodeOffsets,
                          const QVariantList& beamStress);
  void failed();
  void converged();

private:
  void emitCompleted(const Output& o);
  void applyOutputToInput(const Output& o);

private:
  Input* in_;
  Eigen::VectorXf gravityForces_;
  Eigen::VectorXf stressForces_;
  float relaxation_;
};

inline void FEAnalyzer::setRelaxation(float r) {
    if (r != relaxation_) {
        relaxation_ = r;
        emit relaxationChanged();
    }
}

inline float FEAnalyzer::relaxation() const {
    return relaxation_;
}

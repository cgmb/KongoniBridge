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
public:
    explicit FEAnalyzer();
    virtual ~FEAnalyzer();

public slots:
  void processBridge(const QVariantList& nodes,
                     const QVariantList& beams);
  void step();

signals:
  void processingComplete(const QVariantList& nodeOffsets,
                          const QVariantList& beamStress);
  void failed();
  void converged();

private:
  void emitCompleted(const Output& o);

private:
  Input* in_;
  Eigen::VectorXf gravityForces_;
  Eigen::VectorXf stressForces_;
};

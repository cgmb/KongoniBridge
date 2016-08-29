#pragma once

#include <QObject>
#include <QVariantList>
#include "Vec2f.h"

class FEAnalyzer : public QObject {
  Q_OBJECT
public slots:
  void processBridge(const QVariantList& nodes,
                     const QVariantList& beams);

signals:
  void processingComplete(const QVariantList& nodeOffsets,
                          const QVariantList& beamStress);
};

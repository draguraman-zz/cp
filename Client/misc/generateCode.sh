#!/bin/sh

BALLS=15
i=0
while [ ${i} -lt $BALLS ] ; do
echo "if(result.ball_${i}_x) { m_balls[${i}].x = result.ball_${i}_x; m_balls[${i}].y = result.ball_${i}_y; m_balls[${i}].vx = result.ball_${i}_vx; m_balls[${i}].vy = result.ball_${i}_vy; }"
echo "else { m_balls[${i}].visible = false; } "
i=`expr ${i} + 1`
done

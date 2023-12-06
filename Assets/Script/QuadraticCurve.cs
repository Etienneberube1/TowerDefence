using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class QuadraticCurve : MonoBehaviour
{
    public Transform pointA;
    public Transform pointB;
    public Transform curveControl;


    public Vector3 evaluate(float t) {
        Vector3 ac = Vector3.Lerp(pointA.position, curveControl.position, t);
        Vector3 cb = Vector3.Lerp(curveControl.position, pointB.position, t);
        return Vector3.Lerp(ac, cb, t);
    }


    private void OnDrawGizmos()
    {
        if (curveControl == null || pointA == null || pointB == null) return;

        for (int i = 0; i < 300; i++) {
            Gizmos.DrawWireSphere(evaluate(i / 300f), 5f);
        }
    }
}

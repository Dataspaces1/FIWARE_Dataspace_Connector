# FIWARE_Dataspace_Connector
The FIWARE Dataspace Connector got implemented.
![image](https://github.com/user-attachments/assets/1ad371e3-32bd-46ff-a307-c180e9999465)

![image](https://github.com/user-attachments/assets/ae05ab3b-14a7-461f-9dd9-4b5cfb51227f)

![image](https://github.com/user-attachments/assets/bc54240a-ccbf-466b-acaf-1e34ce433bdf)

![image](https://github.com/user-attachments/assets/4d97b75e-cb97-4650-bc80-4a104e485ff6)

![image](https://github.com/user-attachments/assets/2416dd3a-2cdb-499c-bb48-e39b4415a0eb)

.....................

second workshop

![image](https://github.com/user-attachments/assets/94f9fae8-88f6-4957-8852-63843387dc23)

kubectl apply -f https://raw.githubusercontent.com/rancher/local-path-provisioner/v0.0.30/deploy/local-path-storage.yaml

sudo k3s kubectl apply -f https://raw.githubusercontent.com/rancher/local-path-provisioner/v0.0.30/deploy/local-path-storage.yaml

................

Test Persistent Volume Creation: Test the functionality by creating a PersistentVolumeClaim (PVC):

apiVersion: v1
kind: PersistentVolumeClaim
metadata:
  name: test-pvc
spec:
  accessModes:
    - ReadWriteOnce
  resources:
    requests:
      storage: 1Gi
  storageClassName: local-path

..................



Save this to a file (e.g., test-pvc.yaml) and apply it:

k3s kubectl apply -f test-pvc.yaml

.............

Verify PVC and PV: After applying the PVC, check if it gets bound to a PersistentVolume:

k3s kubectl get pvc
k3s kubectl get pv

...................

Test Pod Using PVC: Deploy a test pod that uses this PVC:

apiVersion: v1
kind: Pod
metadata:
  name: test-pod
spec:
  containers:
  - name: test-container
    image: busybox
    command: ["sleep", "3600"]
    volumeMounts:
    - mountPath: "/test-pvc"
      name: test-volume
  volumes:
  - name: test-volume
    persistentVolumeClaim:
      claimName: test-pvc

......................

Save this as test-pod.yaml and apply it:

k3s kubectl apply -f test-pod.yaml

.....................

k3s kubectl get pod test-pod
k3s kubectl exec -it test-pod -- ls /test-pvc

.....................

This process confirms that the local-path-provisioner is properly configured and functional.

..............

![image](https://github.com/user-attachments/assets/3d05f044-c15c-4415-b445-f648631eae42)


















Resources
1. https://github.com/FIWARE/data-space-connector/blob/main/doc/deployment-integration/local-deployment/LOCAL.MD
2. https://github.com/wistefan/deployment-demo
3. httpe://github.com/wistefan/presentations
4. https://github.com/FIWARE/data-space-connector

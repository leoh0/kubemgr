# KubeMGR: Manage kubernetes cluster configurations

kubernetes 는 cluster config를 context를 통해 관리하기 때문에 다수의 cluster config를 편하게 관리 할 수 있으나 context는 새로운 shell에서도 유지되기 때문에 다수의 cluster를 동시에 작업하려면 계속 context를 변경해야 하기 때문에 불편할 수 있습니다. 만약 다수의 분리된 cluster config를 사용하며 사용할때 각각 `kubectl --kubeconfig` `export KUBECONFIG=` 를 하는 방법도 있으나 매번 타이핑 해서 사용 하기엔 불편 할 수 있습니다. 그래서 이런 문제들을 해결하고자 프로젝트를 만들 었습니다.

그래서 `kubemgr`은 아래와 같은 기능을 제공합니다.

* 일반적으로 `${HOME}/.kube/config`를 global shell 환경에서 기존과 같은 방법으로 이용하도록 합니다.
* 특정 디렉토리 안에서는 특정한 cluster를 자동으로 사용 하고 디렉토리에서 나올 시 다시 기본 cluster config를 사용 하도록 합니다.
* 각각의 config를 directory로 관리하고 이를 merge 해서 `${HOME}/.kube/config` 를 생성함으로 손쉽게 특정 cluster config를 추가/제거 가능합니다.
* `kubeadm` 등과 같은 툴로 전부 동일하게 생성된 config들을 자동으로 디렉토리 이름에 맞게 변경해서 손쉽게 등록 가능합니다.

## 사전 준비

* [autoenv 설치](https://github.com/kennethreitz/autoenv) 참고
* 디렉토리를 나갈시에도 작동하도록 하는 기능과 `AUTOENV_ENABLE_LEAVE=true`, autoenv를 인터렉션 없이 등록해주기 위한 변수 `AUTOENV_ASSUME_YES=true`를 등록합니다.

```bash
# autoenv 설치
git clone git://github.com/kennethreitz/autoenv.git ~/.autoenv
echo 'source ~/.autoenv/activate.sh' | tee -a ~/.bashrc
# authenv 환경 변수 세팅
echo 'export AUTOENV_ENABLE_LEAVE=true' | tee -a ~/.bashrc
echo 'export AUTOENV_ASSUME_YES=true' | tee -a ~/.bashrc
# 현재 shell에도 등록
source ~/.autoenv/activate.sh
export AUTOENV_ENABLE_LEAVE=true
export AUTOENV_ASSUME_YES=true
```

## 사용 방법

### 컨피그 등록

1. 이 git을 적당히 작업디렉토리로 사용할 곳으로 clone 합니다.

    ```bash
    git clone https://github.com/leoh0/kubemgr ~/work
    ```

1. cluster 이름으로 사용할 디렉토리를 생성합니다.

    ```bash
    CLUSTER_NAME=<YOUR CLUSTER NAME HERE>
    mkdir -p "${CLUSTER_NAME}"
    ```

1. 해당 디렉토리 안에 `kubeconfig` 이름으로 config를 복사해서 넣습니다.

    ```bash
    echo '''<CONFIG CONTENTS HERE>''' | tee "${CLUSTER_NAME}/kubeconfig"
    ```

1. 이후 해당 디렉토리로 이동하여 자동으로 컨피그가 로딩되는지 확인 합니다.

    ```bash
    cd "${CLUSTER_NAME}"
    ```

1. 해당 디렉토리에서 바깥 디렉토리로 이동시 기존의 원래 컨피그가 로딩되는지 확인 합니다.

    ```bash
    cd -
    ```

* example

```bash
$ CLUSTER_NAME=minikube
$ mkdir -p "${CLUSTER_NAME}"
$ echo '''apiVersion: v1
clusters:
- cluster:
    certificate-authority: /Users/al/.minikube/ca.crt
    server: https://192.168.64.3:8443
  name: minikube
contexts:
- context:
    cluster: minikube
    user: minikube
  name: minikube
current-context: minikube
kind: Config
preferences: {}
users:
- name: minikube
  user:
    client-certificate: /Users/al/.minikube/client.crt
    client-key: /Users/al/.minikube/client.key
''' | tee "${CLUSTER_NAME}/kubeconfig"
$ cd minikube/
Set config to minikube
$ kubectl cluster-info
Kubernetes master is running at https://192.168.64.3:8443
KubeDNS is running at https://192.168.64.3:8443/api/v1/namespaces/kube-system/services/kube-dns:dns/proxy

To further debug and diagnose cluster problems, use 'kubectl cluster-info dump'.
```

### 컨피그 제거

해당 디렉토리를 삭제 합니다.

### 디렉토리들의 컨피그와 기존 컨피그의 병합

현재 디렉토리들 안의 config들과 `${HOME}/.kube/config`를 합쳐서 기존의 `${HOME}/.kube/config`를 교체해서 저장 할 수 있도록 합니다.

```bash
./merge.sh
```

### 디렉토리들의 컨피그를 병합하여 기존 컨피그를 교체

현재 디렉토리들 안의 config들을 합쳐서 기존의 `${HOME}/.kube/config`를 교체해서 저장 할 수 있도록 합니다.

```bash
./replace.sh
```
